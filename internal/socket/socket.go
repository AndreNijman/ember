// Package socket holds the path + dial helpers for the aqs Unix socket.
package socket

import (
	"bufio"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"time"

	"github.com/AndreNijman/aqs/internal/proto"
)

func Path() string {
	if p := os.Getenv("AQS_SOCKET"); p != "" {
		return p
	}
	runtime := os.Getenv("XDG_RUNTIME_DIR")
	if runtime == "" {
		runtime = filepath.Join(os.TempDir(), fmt.Sprintf("aqs-%d", os.Getuid()))
		_ = os.MkdirAll(runtime, 0o700)
	}
	return filepath.Join(runtime, "aqs.sock")
}

func Dial() (net.Conn, error) {
	p := Path()
	conn, err := net.DialTimeout("unix", p, 2*time.Second)
	if err != nil {
		return nil, fmt.Errorf("dial %s: %w", p, err)
	}
	return conn, nil
}

func SendRequest(req proto.Request) (proto.Response, error) {
	var resp proto.Response
	conn, err := Dial()
	if err != nil {
		return resp, err
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(5 * time.Second))
	if err := proto.WriteFrame(conn, req); err != nil {
		return resp, err
	}
	r := bufio.NewReader(conn)
	if err := proto.ReadFrame(r, &resp); err != nil {
		return resp, err
	}
	if !resp.OK && resp.Error == "" {
		return resp, errors.New("unknown error")
	}
	return resp, nil
}
