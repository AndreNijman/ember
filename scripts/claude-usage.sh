#!/usr/bin/env bash
# claude-usage.sh — JSON summary of Claude Code usage for ember's ClaudePill.
# Reads local ccusage data — no API keys or network calls required.
#
# Set env vars to match your plan (cost-based limits, USD-equivalent):
#   EMBER_CLAUDE_MAX_5H_COST=50     per 5-hour block
#   EMBER_CLAUDE_MAX_WEEK_COST=500  per week

MAX_5H_COST="${EMBER_CLAUDE_MAX_5H_COST:-50}"
MAX_WEEK_COST="${EMBER_CLAUDE_MAX_WEEK_COST:-500}"

# Locate ccusage: respect CCUSAGE_BIN env, then PATH, then pnpm default
CCUSAGE="${CCUSAGE_BIN:-$(command -v ccusage 2>/dev/null || echo "${HOME}/.local/share/pnpm/ccusage")}"

if [[ ! -x "$CCUSAGE" ]]; then
    printf '{"valid":false}\n'
    exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

"$CCUSAGE" blocks -a --offline --json > "$TMP/b.json" 2>/dev/null \
    || printf '{"blocks":[]}' > "$TMP/b.json"
"$CCUSAGE" weekly --offline --json > "$TMP/w.json" 2>/dev/null \
    || printf '{"weekly":[]}' > "$TMP/w.json"

python3 - "$TMP/b.json" "$TMP/w.json" "$MAX_5H_COST" "$MAX_WEEK_COST" <<'EOF'
import json, datetime, sys

try:
    with open(sys.argv[1]) as f: blocks = json.load(f).get('blocks', [])
    with open(sys.argv[2]) as f: weekly = json.load(f).get('weekly', [])
    max_5h   = float(sys.argv[3])
    max_week = float(sys.argv[4])
except Exception:
    print('{"valid":false}')
    sys.exit(0)

now = datetime.datetime.now(datetime.timezone.utc)

# 5h block
active = next((b for b in blocks if b.get('isActive') and not b.get('isGap')), None)
cost_5h    = float(active.get('costUSD', 0)) if active else 0.0
proj       = (active.get('projection') or {}) if active else {}
reset_mins = int(proj.get('remainingMinutes', 0))
hour5_pct  = min(100.0, cost_5h / max_5h * 100) if max_5h else 0.0

# Current week (ccusage week keys are Monday start dates)
week_cost = 0.0
for w in reversed(weekly):
    try:
        wd = datetime.datetime.strptime(w['week'], '%Y-%m-%d').replace(tzinfo=datetime.timezone.utc)
        if 0 <= (now - wd).days < 7:
            week_cost = float(w.get('totalCost', 0))
            break
    except Exception:
        pass
week_pct = min(100.0, week_cost / max_week * 100) if max_week else 0.0

# Minutes until next Monday 00:00 UTC (weekly reset)
days_to_mon = (7 - now.weekday()) % 7 or 7
next_mon    = (now + datetime.timedelta(days=days_to_mon)).replace(
    hour=0, minute=0, second=0, microsecond=0)
week_reset_mins = max(0, int((next_mon - now).total_seconds() / 60))

print(json.dumps({
    'valid':          True,
    'hour5Pct':       round(hour5_pct, 1),
    'hour5ResetMins': reset_mins,
    'weekPct':        round(week_pct, 1),
    'weekResetMins':  week_reset_mins,
}))
EOF
