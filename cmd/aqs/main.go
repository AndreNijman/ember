// Command aqs is the IPC client + PAM helper for the arch-quickshell-shell.
package main

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/signal"
	"os/user"
	"strings"
	"syscall"
	"time"

	"github.com/AndreNijman/aqs/internal/ipc"
	"github.com/AndreNijman/aqs/internal/pam"
	"github.com/AndreNijman/aqs/internal/proto"
	"github.com/AndreNijman/aqs/internal/socket"
)

const usage = `aqs — arch-quickshell-shell IPC client + helpers

usage:
  aqs ipc <target> <action> [args...]
  aqs ipc status
  aqs pam authenticate [--service login] [--user $USER]
  aqs serve [--stub]
  aqs version
  aqs doctor
  aqs restart
  aqs keybinds
  aqs wallpaper <path>
`

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 {
		fmt.Print(usage)
		return nil
	}
	switch args[0] {
	case "version", "--version", "-v":
		v := proto.ProtocolVersion
		fmt.Printf("aqs %d.%d.%d\n", v.Major, v.Minor, v.Patch)
		return nil
	case "ipc":
		return runIPC(args[1:])
	case "pam":
		return runPAM(args[1:])
	case "serve":
		return runServe(args[1:])
	case "doctor":
		return runDoctor()
	case "restart":
		return ipc.RunClient("shell", "restart", nil)
	case "keybinds":
		return ipc.RunClient("shell", "keybinds", nil)
	case "wallpaper":
		return ipc.RunClient("wallpaper", "set", args[1:])
	case "help", "--help", "-h":
		fmt.Print(usage)
		return nil
	default:
		return fmt.Errorf("unknown command %q\n%s", args[0], usage)
	}
}

func runIPC(args []string) error {
	if len(args) == 0 {
		return errors.New("aqs ipc: missing target")
	}
	if len(args) == 1 {
		// aqs ipc status -> shell status shortcut
		return ipc.RunClient("shell", args[0], nil)
	}
	target := args[0]
	action := args[1]
	rest := args[2:]
	return ipc.RunClient(target, action, rest)
}

func runPAM(args []string) error {
	if len(args) == 0 || args[0] != "authenticate" {
		return errors.New("aqs pam: only 'authenticate' is supported")
	}
	service := "login"
	var username string
	i := 1
	for i < len(args) {
		switch args[i] {
		case "--service":
			if i+1 >= len(args) {
				return errors.New("--service needs value")
			}
			service = args[i+1]
			i += 2
		case "--user":
			if i+1 >= len(args) {
				return errors.New("--user needs value")
			}
			username = args[i+1]
			i += 2
		default:
			return fmt.Errorf("unknown arg %q", args[i])
		}
	}
	if username == "" {
		u, err := user.Current()
		if err != nil {
			return err
		}
		username = u.Username
	}
	password, err := readPassword(os.Stdin)
	if err != nil {
		return err
	}
	if err := pam.Authenticate(service, username, password); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	return nil
}

func readPassword(r io.Reader) (string, error) {
	br := bufio.NewReader(r)
	line, err := br.ReadString('\n')
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	return strings.TrimRight(line, "\r\n"), nil
}

func runServe(args []string) error {
	stub := false
	for _, a := range args {
		if a == "--stub" {
			stub = true
		}
	}
	if !stub {
		return errors.New("only --stub serve is implemented in the go binary; the real server is the Quickshell Ipc singleton")
	}
	srv := ipc.NewServer(nil)
	if err := srv.Start(); err != nil {
		return err
	}
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	fmt.Fprintf(os.Stderr, "aqs serve --stub listening on %s\n", socket.Path())
	return srv.Serve(ctx)
}

func runDoctor() error {
	report := map[string]any{
		"version": proto.ProtocolVersion,
		"socket":  socket.Path(),
	}
	if _, err := os.Stat(socket.Path()); err == nil {
		report["socketExists"] = true
		// attempt a status round trip
		conn, err := socket.Dial()
		if err == nil {
			_ = conn.SetDeadline(time.Now().Add(1 * time.Second))
			_ = proto.WriteFrame(conn, proto.Request{Version: proto.ProtocolVersion, Target: "shell", Action: "status"})
			report["roundTrip"] = "attempted"
			conn.Close()
		} else {
			report["roundTripErr"] = err.Error()
		}
	} else {
		report["socketExists"] = false
	}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	return enc.Encode(report)
}
