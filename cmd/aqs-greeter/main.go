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
	"strings"
	"sync"
	"syscall"
)

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

type session struct {
	mu        sync.Mutex
	conn      net.Conn
	username  string
	command   []string
	configArg string
}

func (s *session) auth(user, pass string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.conn != nil {
		_ = s.conn.Close()
		s.conn = nil
	}

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
			return err
		}
		switch r.Type {
		case "success":
			return nil
		case "error":
			return fmt.Errorf("%s: %s", r.ErrorType, r.Description)
		case "auth_message":
			// Reply with password regardless of message type for now.
			if err := sendGreetd(c, greetdReq{Type: "post_auth_message_response", Response: pass}); err != nil {
				return err
			}
		default:
			return fmt.Errorf("unexpected greetd response: %s", r.Type)
		}
	}
}

func (s *session) start() error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.conn == nil {
		return fmt.Errorf("no authenticated session")
	}
	cmd := append([]string{}, s.command...)
	if s.configArg != "" {
		cmd = append(cmd, "-c", s.configArg)
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
	var command, config, qmlPath string
	flag.StringVar(&command, "command", "Hyprland", "session command to start on success")
	flag.StringVar(&config, "config", "", "compositor config (passed as `-c <path>`) ")
	flag.StringVar(&qmlPath, "qml", "/usr/share/aqs-greeter/greeter.qml", "path to greeter qml")
	flag.Parse()

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

	sess := &session{command: []string{command}, configArg: config}

	qs := exec.Command("quickshell", "-p", qmlPath)
	qs.Stderr = os.Stderr
	qs.Stdout = os.Stderr
	qs.Env = append(os.Environ(),
		"AQS_GREETER_SOCK="+sockPath,
	)
	if err := qs.Start(); err != nil {
		log.Fatalf("spawn quickshell: %v", err)
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
