// Package proto defines the newline-delimited JSON wire format for aqs IPC.
package proto

import (
	"bufio"
	"encoding/json"
	"errors"
	"io"
)

type Version struct {
	Major int `json:"major"`
	Minor int `json:"minor"`
	Patch int `json:"patch"`
}

var ProtocolVersion = Version{Major: 0, Minor: 1, Patch: 0}

type Request struct {
	Version Version         `json:"version"`
	Target  string          `json:"target"`
	Action  string          `json:"action"`
	Args    json.RawMessage `json:"args,omitempty"`
	ID      string          `json:"id,omitempty"`
}

type Response struct {
	OK    bool            `json:"ok"`
	Value json.RawMessage `json:"value,omitempty"`
	Error string          `json:"error,omitempty"`
	ID    string          `json:"id,omitempty"`
}

func WriteFrame(w io.Writer, v any) error {
	data, err := json.Marshal(v)
	if err != nil {
		return err
	}
	data = append(data, '\n')
	_, err = w.Write(data)
	return err
}

func ReadFrame(r *bufio.Reader, v any) error {
	line, err := r.ReadBytes('\n')
	if err != nil {
		if errors.Is(err, io.EOF) && len(line) == 0 {
			return io.EOF
		}
		if len(line) == 0 {
			return err
		}
	}
	return json.Unmarshal(line, v)
}
