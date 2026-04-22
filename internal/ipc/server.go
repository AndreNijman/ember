// Package ipc implements the aqs Unix-socket JSON server used by the QML shell
// and CLI clients. The server is stub-grade: it validates the protocol, routes
// by target/action, and returns structured responses. Real state mutations are
// handled inside Quickshell (QML-side Ipc singleton) when the shell is live.
// The Go stub server exists only so `aqs ipc status` can round-trip during
// build verification when Quickshell is not running.
package ipc

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"sync"
	"time"

	"github.com/AndreNijman/aqs/internal/proto"
	"github.com/AndreNijman/aqs/internal/socket"
)

type Server struct {
	listener net.Listener
	started  time.Time
	mu       sync.Mutex
	log      *log.Logger
}

func NewServer(logger *log.Logger) *Server {
	if logger == nil {
		logger = log.New(os.Stderr, "[aqs-ipc] ", log.LstdFlags)
	}
	return &Server{log: logger}
}

func (s *Server) Start() error {
	p := socket.Path()
	_ = os.Remove(p)
	l, err := net.Listen("unix", p)
	if err != nil {
		return fmt.Errorf("listen %s: %w", p, err)
	}
	if err := os.Chmod(p, 0o600); err != nil {
		_ = l.Close()
		return fmt.Errorf("chmod %s: %w", p, err)
	}
	s.listener = l
	s.started = time.Now()
	return nil
}

func (s *Server) Addr() string { return socket.Path() }

func (s *Server) Serve(ctx context.Context) error {
	go func() {
		<-ctx.Done()
		_ = s.listener.Close()
	}()
	for {
		conn, err := s.listener.Accept()
		if err != nil {
			if errors.Is(ctx.Err(), context.Canceled) || errors.Is(ctx.Err(), context.DeadlineExceeded) {
				return nil
			}
			var ne net.Error
			if errors.As(err, &ne) && ne.Timeout() {
				continue
			}
			return err
		}
		go s.handle(conn)
	}
}

func (s *Server) handle(conn net.Conn) {
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(10 * time.Second))
	r := bufio.NewReader(conn)
	var req proto.Request
	if err := proto.ReadFrame(r, &req); err != nil {
		s.log.Printf("read: %v", err)
		return
	}
	resp := s.dispatch(req)
	resp.ID = req.ID
	if err := proto.WriteFrame(conn, resp); err != nil {
		s.log.Printf("write: %v", err)
	}
}

func (s *Server) dispatch(req proto.Request) proto.Response {
	if req.Target == "" && req.Action == "status" {
		return s.status()
	}
	if req.Target == "shell" && req.Action == "version" {
		return ok(map[string]any{"version": proto.ProtocolVersion})
	}
	if req.Target == "shell" && req.Action == "status" {
		return s.status()
	}
	return errResp(fmt.Sprintf("stub: target=%q action=%q not implemented in go server (run quickshell)", req.Target, req.Action))
}

func (s *Server) status() proto.Response {
	s.mu.Lock()
	defer s.mu.Unlock()
	uptime := time.Since(s.started).Round(time.Second).Seconds()
	val := map[string]any{
		"version":   proto.ProtocolVersion,
		"pid":       os.Getpid(),
		"socket":    socket.Path(),
		"uptimeSec": uptime,
		"backend":   "go-stub",
	}
	return ok(val)
}

func ok(v any) proto.Response {
	data, _ := json.Marshal(v)
	return proto.Response{OK: true, Value: data}
}

func errResp(msg string) proto.Response {
	return proto.Response{OK: false, Error: msg}
}
