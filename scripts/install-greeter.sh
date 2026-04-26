#!/usr/bin/env bash
#
# install-greeter.sh — install the ember greeter as the default greetd
# session. Backs up any existing /etc/greetd/config.toml and
# /etc/greetd/hyprland.conf with a timestamped suffix so you can revert.
#
# Idempotent: re-running re-installs the latest binary + qml + config and
# stacks one new backup per run.
#
# Requires: sudo, greetd, quickshell, start-hyprland.
#
# Usage:
#   ./scripts/install-greeter.sh                  # install (uses files in ./build)
#   ./scripts/install-greeter.sh --uninstall      # restore the most recent backup
#   AQS_GREETER_PREFIX=/usr ./scripts/install-greeter.sh
set -euo pipefail

PREFIX="${AQS_GREETER_PREFIX:-/usr/local}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build"
TS="$(date +%Y%m%d-%H%M%S)"

require() {
    command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }
}

check_deps() {
    require greetd
    require quickshell
    require start-hyprland
}

backup() {
    local f="$1"
    [[ -e "$f" ]] || return 0
    sudo cp -a "$f" "$f.bak-pre-aqs-$TS"
    echo "  backup: $f.bak-pre-aqs-$TS"
}

uninstall() {
    local latest_cfg
    latest_cfg=$(sudo bash -c 'ls -1t /etc/greetd/config.toml.bak-pre-aqs-* 2>/dev/null | head -1' || true)
    if [[ -z "$latest_cfg" ]]; then
        echo "no aqs backups found in /etc/greetd/; nothing to revert" >&2
        exit 1
    fi
    echo "restoring $latest_cfg → /etc/greetd/config.toml"
    sudo cp -a "$latest_cfg" /etc/greetd/config.toml
    local latest_hypr
    latest_hypr=$(sudo bash -c 'ls -1t /etc/greetd/hyprland.conf.bak-pre-aqs-* 2>/dev/null | head -1' || true)
    if [[ -n "$latest_hypr" ]]; then
        echo "restoring $latest_hypr → /etc/greetd/hyprland.conf"
        sudo cp -a "$latest_hypr" /etc/greetd/hyprland.conf
    fi
    sudo systemctl reset-failed greetd
    sudo systemctl restart greetd
    echo "done"
    exit 0
}

if [[ "${1:-}" == "--uninstall" ]]; then
    uninstall
fi

check_deps

if [[ ! -x "$BUILD_DIR/aqs-greeter" || ! -f "$REPO_ROOT/qml/greeter.qml" ]]; then
    echo "build artefacts missing; running 'make build'..."
    (cd "$REPO_ROOT" && make build)
fi

echo "==> installing greeter binary + assets"
sudo install -Dm755 "$BUILD_DIR/aqs-greeter"          "$PREFIX/bin/aqs-greeter"
sudo install -Dm644 "$REPO_ROOT/qml/greeter.qml"      /usr/share/aqs-greeter/greeter.qml
sudo install -d /usr/share/aqs-greeter/Theme
sudo install -Dm644 "$REPO_ROOT/qml/Theme/Theme.qml"  /usr/share/aqs-greeter/Theme/Theme.qml
sudo install -Dm644 "$REPO_ROOT/qml/Theme/Tokens.qml" /usr/share/aqs-greeter/Theme/Tokens.qml
sudo install -Dm644 "$REPO_ROOT/qml/Theme/Fonts.qml"  /usr/share/aqs-greeter/Theme/Fonts.qml
sudo install -Dm644 "$REPO_ROOT/qml/Theme/qmldir"     /usr/share/aqs-greeter/Theme/qmldir
sudo chmod -R a+rX /usr/share/aqs-greeter

echo "==> backing up + writing /etc/greetd/config.toml"
backup /etc/greetd/config.toml
sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "$PREFIX/bin/aqs-greeter -command start-hyprland -hypr-config /etc/greetd/hyprland.conf -qml /usr/share/aqs-greeter/greeter.qml"
user = "greeter"
EOF

echo "==> backing up + writing /etc/greetd/hyprland.conf"
backup /etc/greetd/hyprland.conf
sudo tee /etc/greetd/hyprland.conf >/dev/null <<'EOF'
monitor = , preferred, auto, 1

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
}

debug {
    disable_logs = true
    suppress_errors = true
    enable_stdout_logs = false
}

input {
    kb_layout = us
}

# AQS_GREETER_QML/SOCK are inherited from the parent aqs-greeter binary.
exec-once = sh -c 'quickshell -p "$AQS_GREETER_QML" >>/tmp/aqs-greeter.log 2>&1'
EOF

echo "==> resetting greetd"
sudo systemctl reset-failed greetd
sudo systemctl restart greetd

echo
echo "Greeter installed. Switch to TTY1 (Ctrl+Alt+F1) to verify before logout."
echo "To revert: $0 --uninstall"
