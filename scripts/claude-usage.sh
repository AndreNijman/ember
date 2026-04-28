#!/usr/bin/env bash
# claude-usage.sh — read Claude Code's real rate-limit cache for ember's ClaudePill.
# Data is written by the claude-pace.sh statusline hook (no API calls here).
# Cache format: u5 SEP u7 SEP r5_epoch SEP r7_epoch  (ASCII 0x1F separator)

SEP=$'\037'

# Mirror claude-pace.sh's cache directory search
CACHE=""
for BASE in "${XDG_RUNTIME_DIR:-}" "${HOME}/.cache"; do
    [[ -n "$BASE" ]] || continue
    CAND="${BASE%/}/claude-pace/claude-sl-quota"
    if [[ -f "$CAND" ]]; then
        CACHE="$CAND"
        break
    fi
done

if [[ -z "$CACHE" ]]; then
    printf '{"valid":false}\n'
    exit 0
fi

line=$(cat "$CACHE" 2>/dev/null)
[[ -z "$line" ]] && { printf '{"valid":false}\n'; exit 0; }

if [[ "$line" == *"$SEP"* ]]; then
    IFS=$'\037' read -r u5 u7 r5 r7 <<< "$line"
else
    IFS='|' read -r u5 u7 r5 r7 <<< "$line"
fi

# Require numeric usage values
[[ "$u5" =~ ^[0-9]+$ ]] && [[ "$u7" =~ ^[0-9]+$ ]] || { printf '{"valid":false}\n'; exit 0; }

NOW=$(date +%s)
r5_mins=$(( (r5 - NOW) / 60 )); (( r5_mins < 0 )) && r5_mins=0
r7_mins=$(( (r7 - NOW) / 60 )); (( r7_mins < 0 )) && r7_mins=0

printf '{"valid":true,"hour5Pct":%s,"hour5ResetMins":%d,"weekPct":%s,"weekResetMins":%d}\n' \
    "$u5" "$r5_mins" "$u7" "$r7_mins"
