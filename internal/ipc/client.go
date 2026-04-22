package ipc

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/AndreNijman/aqs/internal/proto"
	"github.com/AndreNijman/aqs/internal/socket"
)

func RunClient(target, action string, args []string) error {
	var raw json.RawMessage
	if len(args) > 0 {
		data, err := json.Marshal(args)
		if err != nil {
			return err
		}
		raw = data
	}
	req := proto.Request{
		Version: proto.ProtocolVersion,
		Target:  target,
		Action:  action,
		Args:    raw,
	}
	resp, err := socket.SendRequest(req)
	if err != nil {
		return err
	}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if err := enc.Encode(resp); err != nil {
		return err
	}
	if !resp.OK {
		return fmt.Errorf("ipc error: %s", resp.Error)
	}
	return nil
}
