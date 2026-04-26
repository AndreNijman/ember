// Command aqs-greeter is the ember greetd greeter.
//
// It speaks the greetd JSON protocol (over $GREETD_SOCK) to authenticate a
// user and start their session, while delegating the UI to a Quickshell
// process running qml/greeter.qml. The greeter QML talks to this binary
// over a private Unix socket whose path is exposed via $AQS_GREETER_SOCK.
//
// Wire protocol between QML and this binary (newline-delimited):
//   QML  -> auth <username> <password>
//   QML  -> start
//   QML  -> power off|reboot
//   bin  -> ok
//   bin  -> err <message>
//   bin  -> prompt <message>           (informational; QML may show)
package main

import (
	"bufio"
	"encoding/binary"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"syscall"
)

// lastLoginUser shells out to `last -F` and returns the most recent
// non-system user (skipping reboot/wtmp markers). Returns empty on miss.
func lastLoginUser() string {
	out, err := exec.Command("last", "-F").Output()
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(out), "\n") {
		f := strings.Fields(line)
		if len(f) == 0 {
			continue
		}
		switch f[0] {
		case "reboot", "wtmp", "shutdown", "":
			continue
		}
		return f[0]
	}
	return ""
}

// defaultUser prefers the most recently logged-in user, falling back
// to the first /etc/passwd entry with UID >= 1000.
func defaultUser() string {
	if u := lastLoginUser(); u != "" {
		return u
	}
	return firstHumanUser()
}

// firstHumanUser scans /etc/passwd for the first account with UID >= 1000,
// UID < 65000, and a /home/* home directory. Returns empty string on miss.
func firstHumanUser() string {
	f, err := os.Open("/etc/passwd")
	if err != nil {
		return ""
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		fields := strings.Split(sc.Text(), ":")
		if len(fields) < 7 {
			continue
		}
		uid, err := strconv.Atoi(fields[2])
		if err != nil {
			continue
		}
		if uid < 1000 || uid >= 65000 {
			continue
		}
		if !strings.HasPrefix(fields[5], "/home/") {
			continue
		}
		return fields[0]
	}
	return ""
}

type greetdReq struct {
	Type     string   `json:"type"`
	Username string   `json:"username,omitempty"`
	Response string   `json:"response,omitempty"`
	Cmd      []string `json:"cmd,omitempty"`
	Env      []string `json:"env,omitempty"`
}

type greetdResp struct {
	Type            string `json:"type"`
	AuthMessageType string `json:"auth_message_type,omitempty"`
	AuthMessage     string `json:"auth_message,omitempty"`
	ErrorType       string `json:"error_type,omitempty"`
	Description     string `json:"description,omitempty"`
}

func sendGreetd(c net.Conn, r greetdReq) error {
	b, err := json.Marshal(r)
	if err != nil {
		return err
	}
	if err := binary.Write(c, binary.NativeEndian, uint32(len(b))); err != nil {
		return err
	}
	_, err = c.Write(b)
	return err
}

func recvGreetd(c net.Conn) (greetdResp, error) {
	var n uint32
	if err := binary.Read(c, binary.NativeEndian, &n); err != nil {
		return greetdResp{}, err
	}
	buf := make([]byte, n)
	if _, err := readFull(c, buf); err != nil {
		return greetdResp{}, err
	}
	var r greetdResp
	err := json.Unmarshal(buf, &r)
	return r, err
}

func readFull(c net.Conn, buf []byte) (int, error) {
	total := 0
	for total < len(buf) {
		n, err := c.Read(buf[total:])
		if err != nil {
			return total, err
		}
		total += n
	}
	return total, nil
}

type sessionEntry struct {
	ID   string   `json:"id"`
	Name string   `json:"name"`
	Exec []string `json:"exec"`
}

// shellSplit is a tiny POSIX-shell-ish splitter that drops desktop-entry
// %f/%U/%i/%c placeholders. Good enough for the Exec= lines the major
// compositors ship.
func shellSplit(s string) []string {
	out := []string{}
	cur := ""
	inSingle, inDouble := false, false
	for _, r := range s {
		switch {
		case r == '\'' && !inDouble:
			inSingle = !inSingle
		case r == '"' && !inSingle:
			inDouble = !inDouble
		case r == ' ' && !inSingle && !inDouble:
			if cur != "" {
				out = append(out, cur)
				cur = ""
			}
		default:
			cur += string(r)
		}
	}
	if cur != "" {
		out = append(out, cur)
	}
	cleaned := []string{}
	for _, tok := range out {
		switch tok {
		case "%f", "%F", "%u", "%U", "%i", "%c", "%k":
			continue
		}
		cleaned = append(cleaned, tok)
	}
	return cleaned
}

func scanSessions() []sessionEntry {
	dirs := []string{"/usr/share/wayland-sessions", "/usr/share/xsessions"}
	seen := map[string]bool{}
	var out []sessionEntry
	for _, dir := range dirs {
		entries, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, e := range entries {
			name := e.Name()
			if !strings.HasSuffix(name, ".desktop") {
				continue
			}
			id := strings.TrimSuffix(name, ".desktop")
			if seen[id] {
				continue
			}
			data, err := os.ReadFile(filepath.Join(dir, name))
			if err != nil {
				continue
			}
			displayName := id
			execLine := ""
			tryExec := ""
			haveBaseName := false
			for _, line := range strings.Split(string(data), "\n") {
				if strings.HasPrefix(line, "Name=") && !haveBaseName {
					displayName = strings.TrimPrefix(line, "Name=")
					haveBaseName = true
				} else if strings.HasPrefix(line, "Exec=") {
					execLine = strings.TrimPrefix(line, "Exec=")
				} else if strings.HasPrefix(line, "TryExec=") {
					tryExec = strings.TrimPrefix(line, "TryExec=")
				}
			}
			if execLine == "" {
				continue
			}
			if tryExec != "" {
				if _, err := exec.LookPath(tryExec); err != nil {
					continue
				}
			}
			out = append(out, sessionEntry{ID: id, Name: displayName, Exec: shellSplit(execLine)})
			seen[id] = true
		}
	}
	return out
}

type session struct {
	mu        sync.Mutex
	conn      net.Conn
	username  string
	command   []string
	configArg string
	sessions  []sessionEntry
	override  string
}

// cancelLocked sends cancel_session on the current conn (if any), drains
// the response, closes the conn. Caller must hold s.mu. Best-effort —
// ignores errors; greetd needs the cancel to free its session slot before
// the next create_session, otherwise it refuses with
// "a session is already configured".
func (s *session) cancelLocked() {
	if s.conn == nil {
		return
	}
	_ = sendGreetd(s.conn, greetdReq{Type: "cancel_session"})
	_, _ = recvGreetd(s.conn)
	_ = s.conn.Close()
	s.conn = nil
}

func (s *session) auth(user, pass string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Always cancel any in-flight session before starting a new one so a
	// previous failed attempt doesn't leave greetd thinking a session is
	// still being configured.
	s.cancelLocked()

	sock := os.Getenv("GREETD_SOCK")
	if sock == "" {
		return fmt.Errorf("GREETD_SOCK not set")
	}
	c, err := net.Dial("unix", sock)
	if err != nil {
		return fmt.Errorf("dial greetd: %w", err)
	}
	s.conn = c
	s.username = user

	if err := sendGreetd(c, greetdReq{Type: "create_session", Username: user}); err != nil {
		return err
	}
	for {
		r, err := recvGreetd(c)
		if err != nil {
			s.cancelLocked()
			return err
		}
		switch r.Type {
		case "success":
			return nil
		case "error":
			msg := fmt.Errorf("%s: %s", r.ErrorType, r.Description)
			s.cancelLocked()
			return msg
		case "auth_message":
			// Reply with password regardless of message type for now.
			if err := sendGreetd(c, greetdReq{Type: "post_auth_message_response", Response: pass}); err != nil {
				s.cancelLocked()
				return err
			}
		default:
			err := fmt.Errorf("unexpected greetd response: %s", r.Type)
			s.cancelLocked()
			return err
		}
	}
}

func (s *session) start() error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.conn == nil {
		return fmt.Errorf("no authenticated session")
	}

	// If the QML side picked a desktop entry from the scanned list, use
	// that entry's Exec verbatim and skip the legacy --command/--config
	// pair entirely.
	var cmd []string
	if s.override != "" {
		for _, se := range s.sessions {
			if se.ID == s.override {
				cmd = append([]string{}, se.Exec...)
				break
			}
		}
	}
	if cmd == nil {
		cmd = append([]string{}, s.command...)
		if s.configArg != "" {
			cmd = append(cmd, "-c", s.configArg)
		}
	}
	if err := sendGreetd(s.conn, greetdReq{Type: "start_session", Cmd: cmd}); err != nil {
		return err
	}
	r, err := recvGreetd(s.conn)
	if err != nil {
		return err
	}
	if r.Type != "success" {
		return fmt.Errorf("start_session: %s", r.Description)
	}
	return nil
}

func handleClient(c net.Conn, sess *session, qsProc *exec.Cmd, done chan<- struct{}) {
	defer c.Close()
	r := bufio.NewReader(c)
	w := bufio.NewWriter(c)
	for {
		line, err := r.ReadString('\n')
		if err != nil {
			return
		}
		line = strings.TrimSpace(line)
		parts := strings.SplitN(line, " ", 3)
		switch parts[0] {
		case "auth":
			if len(parts) != 3 {
				fmt.Fprintf(w, "err bad auth args\n")
				w.Flush()
				continue
			}
			if err := sess.auth(parts[1], parts[2]); err != nil {
				fmt.Fprintf(w, "err %s\n", err.Error())
			} else {
				fmt.Fprintf(w, "ok\n")
			}
			w.Flush()
		case "start":
			if len(parts) >= 2 {
				sess.mu.Lock()
				sess.override = parts[1]
				sess.mu.Unlock()
			}
			if err := sess.start(); err != nil {
				fmt.Fprintf(w, "err %s\n", err.Error())
				w.Flush()
				continue
			}
			fmt.Fprintf(w, "ok\n")
			w.Flush()
			// Tear down QML and exit so greetd starts the session.
			if qsProc != nil && qsProc.Process != nil {
				_ = qsProc.Process.Signal(syscall.SIGTERM)
			}
			close(done)
			return
		case "power":
			if len(parts) < 2 {
				continue
			}
			switch parts[1] {
			case "off":
				_ = exec.Command("systemctl", "poweroff").Start()
			case "reboot":
				_ = exec.Command("systemctl", "reboot").Start()
			}
		}
	}
}

func main() {
	var command, config, qmlPath, hyprBin, hyprConf, logPath string
	flag.StringVar(&command, "command", "Hyprland", "session command to start on success")
	flag.StringVar(&config, "config", "", "session compositor config (passed as `-c <path>`) ")
	flag.StringVar(&qmlPath, "qml", "/usr/share/aqs-greeter/greeter.qml", "path to greeter qml")
	flag.StringVar(&hyprBin, "hypr", "start-hyprland", "compositor binary used to host the greeter UI (start-hyprland silences the unsupported-launch warning)")
	flag.StringVar(&hyprConf, "hypr-config", "/etc/greetd/hyprland.conf", "compositor config used while hosting the greeter UI")
	flag.StringVar(&logPath, "log", "/tmp/aqs-greeter.log", "stderr log path")
	flag.Parse()

	// Redirect own stderr early so we capture downstream errors even when
	// greetd does not surface them.
	if logPath != "" {
		f, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)
		if err == nil {
			os.Stderr = f
			log.SetOutput(f)
			fmt.Fprintf(f, "\n--- aqs-greeter start pid=%d ---\n", os.Getpid())
		}
	}

	if os.Getenv("GREETD_SOCK") == "" {
		log.Fatal("GREETD_SOCK not set; this binary must run under greetd")
	}

	runtime := os.Getenv("XDG_RUNTIME_DIR")
	if runtime == "" {
		runtime = "/tmp"
	}
	sockPath := filepath.Join(runtime, fmt.Sprintf("aqs-greeter-%d.sock", os.Getpid()))
	_ = os.Remove(sockPath)
	ln, err := net.Listen("unix", sockPath)
	if err != nil {
		log.Fatalf("listen %s: %v", sockPath, err)
	}
	defer os.Remove(sockPath)
	defer ln.Close()
	if err := os.Chmod(sockPath, 0600); err != nil {
		log.Printf("chmod %s: %v", sockPath, err)
	}

	sessions := scanSessions()
	sess := &session{command: []string{command}, configArg: config, sessions: sessions}

	defaultUserName := defaultUser()
	sessionsJSON, _ := json.Marshal(sessions)

	// Spawn the host compositor for the greeter VT. The compositor's config
	// is responsible for exec-once'ing quickshell with the greeter QML; the
	// binary just owns the auth socket and waits.
	// start-hyprland does not accept -c; pass the config via HYPRLAND_CONFIG
	// env. Bare Hyprland would also accept the env, so we use it
	// unconditionally and skip the legacy -c flag entirely.
	qs := exec.Command(hyprBin)
	// Suppress compositor stdout/stderr (logs still land in
	// $XDG_RUNTIME_DIR/hypr/*.log) and detach from the controlling TTY so
	// warnings printed straight to /dev/tty (e.g. the uwsm/start-hyprland
	// recommendation) don't bleed onto the bare VT before the greeter layer
	// surface mounts.
	qs.Stdin = nil
	qs.Stdout = nil
	qs.Stderr = nil
	qs.Env = append(os.Environ(),
		"AQS_GREETER_SOCK="+sockPath,
		"AQS_GREETER_QML="+qmlPath,
		"AQS_GREETER_DEFAULT_USER="+defaultUserName,
		"AQS_GREETER_SESSIONS="+string(sessionsJSON),
	)
	if hyprConf != "" {
		qs.Env = append(qs.Env, "HYPRLAND_CONFIG="+hyprConf)
	}
	if err := qs.Start(); err != nil {
		log.Fatalf("spawn %s: %v", hyprBin, err)
	}

	done := make(chan struct{})
	qsExited := make(chan error, 1)
	go func() { qsExited <- qs.Wait() }()

	go func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			go handleClient(c, sess, qs, done)
		}
	}()

	select {
	case <-done:
		// Successful start_session — let greetd take over.
		<-qsExited
	case err := <-qsExited:
		if err != nil {
			log.Printf("quickshell exited with error: %v", err)
		}
	}
}
