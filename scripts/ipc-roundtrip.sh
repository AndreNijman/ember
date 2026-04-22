#!/usr/bin/env bash
# ipc-roundtrip.sh — start `aqs serve --stub`, run `aqs ipc status`, then
# stop the server. Captures both stdout streams and verifies the response
# contains the protocol version. Exit 0 on success.
set -u
AQS="${1:-build/aqs}"
LOG="${2:-build/ipc-roundtrip.log}"
mkdir -p "$(dirname "$LOG")"

: >"$LOG"
"$AQS" serve --stub >>"$LOG" 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null; wait 2>/dev/null' EXIT

# poll for the socket rather than sleep-guess
for _ in $(seq 1 40); do
    if [[ -S "${XDG_RUNTIME_DIR:-/tmp}/aqs.sock" ]]; then break; fi
    sleep 0.05
done

RESP="$("$AQS" ipc status 2>&1)"
echo "--- response ---" >>"$LOG"
echo "$RESP" >>"$LOG"

if echo "$RESP" | grep -q '"major": 0'; then
    echo "ok: round-trip succeeded" | tee -a "$LOG"
    exit 0
fi
echo "fail: unexpected response" | tee -a "$LOG"
exit 1
