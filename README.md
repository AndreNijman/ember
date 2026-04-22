# arch-quickshell-shell

A Quickshell/QML desktop shell for Hyprland on Arch Linux. Built to replace
DMS with a sharper-edged, monochrome aesthetic: 1px hairlines, no rounded
corners, a single amber accent, no blur or shadow.

Status: personal daily driver, pre-release. Expect rough edges.

## What's in it

- Top bar: workspaces, focused-window title, clock, battery, tray
- Launcher: prefix+substring search over `.desktop` entries (system, user, flatpak)
- Control Center: wifi / bluetooth / dnd / idle-hold toggles, audio, brightness,
  battery, power-profile segmented selector, power controls (lock / suspend /
  reboot / off / logout)
- Notification Center: live notifications via Quickshell
- OSD: volume and brightness feedback on media keys
- Lock screen: wayland session-lock with PAM authentication (stub; wire-up incomplete)
- Wallpaper manager: `mpvpaper` per output

## Requirements

- Hyprland (Wayland)
- Quickshell 0.2.1+
- Go 1.21+ (for the `aqs` CLI)
- PAM development headers (`pam` on Arch)
- Runtime helpers: `brightnessctl`, `nmcli`, `powerprofilesctl`, `playerctl`,
  `qalc`, `mpvpaper`, `grim`

## Build

```sh
make all            # go build + vet + qmllint
make ipc-test       # round-trip check
make smoke          # 30s quickshell render soak
```

The Go binary lands in `build/aqs`. Install to `~/.local/bin/aqs` if you want
it on PATH.

## Run

As a systemd user service:

```sh
systemctl --user enable --now aqs.service
```

Or directly:

```sh
quickshell -p qml/shell.qml
```

## IPC

The `aqs` CLI wraps `qs ipc call` and targets QML IpcHandlers in the running
shell. Bind these from Hyprland:

```
aqs ipc launcher toggle
aqs ipc control toggle
aqs ipc notifications toggle
aqs ipc lock engage
aqs ipc audio toggleMute
aqs ipc audio increment 5
aqs ipc brightness increment 5
aqs ipc workspace focus 3
```

Full target list: `shell`, `launcher`, `control`, `notifications`, `lock`,
`osd`, `wallpaper`, `workspace`, `audio`, `brightness`.

## Layout

```
cmd/aqs/              Go CLI entry
internal/             proto, socket, ipc, pam
qml/
  shell.qml           ShellRoot entry
  Theme/              Tokens / Theme / Fonts singletons
  Atoms/              12 primitives
  Services/           15 singletons (Hyprland, Audio, Network, ...)
  Modules/            per-surface trees (TopBar, Launcher, ControlCenter, ...)
scripts/              smoke + ipc-roundtrip
```

See `BUILD_NOTES.md` for the backend status of each service (real vs stub)
and the known gaps.

## License

Unlicensed personal project. Copy freely; no warranty.
