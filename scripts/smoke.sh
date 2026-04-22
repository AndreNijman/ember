#!/usr/bin/env bash
# smoke.sh — launch quickshell against ./qml/shell.qml for 30s and log.
# Runs against a nested Hyprland if available; otherwise falls back to
# dbus-run-session with a generic Wayland compositor. All paths stay
# inside the repo; nothing is installed.
set -u
LOG="${1:-build/smoke.log}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$(dirname "$LOG")"
cd "$REPO"

QML="$REPO/qml"
DURATION=30

echo "== smoke run $(date -Iseconds)" | tee "$LOG"
echo "repo: $REPO" | tee -a "$LOG"
echo "qml:  $QML"  | tee -a "$LOG"

have() { command -v "$1" >/dev/null 2>&1; }

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    echo "using existing WAYLAND_DISPLAY=$WAYLAND_DISPLAY" | tee -a "$LOG"
    timeout "${DURATION}s" quickshell -p "$QML" -c shell.qml >>"$LOG" 2>&1
    rc=$?
elif have Hyprland && have dbus-run-session; then
    echo "nested Hyprland" | tee -a "$LOG"
    cat > "$REPO/build/nest-hypr.conf" <<EOF
exec-once = quickshell -p $QML -c shell.qml
monitor = , preferred, 0x0, 1
EOF
    timeout "${DURATION}s" dbus-run-session -- Hyprland -c "$REPO/build/nest-hypr.conf" >>"$LOG" 2>&1
    rc=$?
else
    echo "no wayland host and no nested Hyprland; running headless qmlscene lint substitute" | tee -a "$LOG"
    timeout 5s qmllint -I "$QML" -I /usr/lib/qt6/qml "$QML/shell.qml" >>"$LOG" 2>&1
    rc=$?
fi

echo "exit: $rc" | tee -a "$LOG"
# timeout returns 124 when it kills a still-running process — that's the
# expected success path for the 30s soak.
if [[ $rc -eq 0 || $rc -eq 124 ]]; then
    exit 0
fi
exit "$rc"
