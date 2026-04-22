# BUILD_NOTES

Initial implementation of the arch-quickshell-shell per the vault specs
(`projects/arch-quickshell-shell.md`, `specs/arch-quickshell-shell/01-04`,
and the four 2026-04-22 decisions).

## Layout

```
arch-quickshell-shell/
├── cmd/aqs/                 Go binary entry point (main.go)
├── internal/
│   ├── proto/               newline-delimited JSON wire types + version
│   ├── socket/              $XDG_RUNTIME_DIR/aqs.sock dial + path helper
│   ├── ipc/                 stub server + CLI client
│   └── pam/                 cgo wrapper around libpam
├── qml/
│   ├── shell.qml            root entry consumed by `quickshell -p qml/shell.qml`
│   ├── Theme/               Tokens, Theme, Fonts singletons
│   ├── Atoms/               12 primitives (Hairline, Surface, Glyph, Cell,
│   │                         Pip, Strip, Bar, Slider, Segments, Toggle,
│   │                         Field, Row)
│   ├── Services/            15 singletons (Hyprland, Clock, Power, Audio,
│   │                         Brightness, Network, Bluetooth, Notif, Idle,
│   │                         Lock, Wallpaper, App, Calc, Tray, Ipc)
│   └── Modules/             per-surface directories: TopBar, Launcher,
│                            NotificationCenter, ControlCenter, OSD, Lock,
│                            WallpaperManager, Shell (root loader)
├── scripts/                 smoke + ipc-roundtrip shell scripts
├── greeter/                 reserved for step-14 greeter config (empty)
├── docs/                    reserved for user-facing docs (empty)
├── build/                   local build output, gitignored
├── go.mod
└── Makefile
```

Task directive said `cmd/aqs/` + `internal/`; spec 04 §2 said `ipc/`.
Task wins. No `ipc/` top-level dir exists; the Go packages live under
`internal/ipc`, `internal/pam`, `internal/proto`, `internal/socket`.

## Real-vs-stub service matrix

| Service             | Backend in this initial cut                                      |
|---------------------|------------------------------------------------------------------|
| HyprlandService     | **Real** — Quickshell.Hyprland workspaces + dispatch             |
| ClockService        | **Real** — native QML Timer, 1s cadence                          |
| PowerService        | **Real** — Quickshell.Services.UPower                            |
| AudioService        | **Real** — Quickshell.Services.Pipewire (dbus, no wpctl)         |
| BluetoothService    | **Real** — Quickshell.Bluetooth                                  |
| NotifService        | **Real** — Quickshell.Services.Notifications                     |
| TrayService         | **Real** — Quickshell.Services.SystemTray                        |
| IdleService         | Surface only — IdleInhibitor wired, idle→lock not hooked yet     |
| LockService         | Surface + `aqs pam authenticate` invocation; wayland session-lock hand-off is out of scope for this commit |
| BrightnessService   | Shells `brightnessctl`; hotplug signals not wired                |
| NetworkService      | Polls `nmcli -t` 4s; full NM dbus deferred                       |
| WallpaperService    | Spawns `mpvpaper` per output; list/thumbnail UI is stub          |
| AppService          | Scans /usr/share/applications + ~/.local/share/applications; frecency log is stub |
| CalcService         | Pipes through `qalc -t`                                          |
| Ipc (QML)           | Quickshell IpcHandler per target/action                          |
| Ipc (Go stub)       | Go server satisfies `shell status` / `shell version` only        |

## Font fallback

Söhne Mono and Inria Serif are commercial and not installed on this
machine. `Theme.Tokens.fontUi` and `Theme.Tokens.fontDisplay` preserve
the spec's primary family names verbatim; Qt walks the comma-delimited
stack at render time. With the fonts unavailable, the UI resolves to
JetBrains Mono + a system serif. No token was edited; no service holds
a literal font family. Install the two families to turn off the fallback.

## `aqs ipc status`

Spec 04 §5 listed targets `bar, launcher, notifications, control, lock,
osd, wallpaper, workspace, shell` but did not define a top-level
`status` action. This binary accepts `aqs ipc status` as a shortcut for
`aqs ipc shell status`, both returning `{version, pid, socket,
uptimeSec, backend}`. The Go stub server sets `backend: "go-stub"`; the
QML-side Ipc singleton returns `backend: "qml"` so you can tell which
endpoint you hit.

## Verification results

All checks run from the repo root; nothing installed system-wide.

| Check                                   | Result |
|-----------------------------------------|--------|
| `go build ./cmd/aqs`                    | clean (cgo libpam linked) |
| `go vet ./...`                          | clean |
| `make lint` (qmllint every .qml, 41 files) | clean |
| `make ipc-test` (`aqs ipc status`)      | `ok: round-trip succeeded` |
| `quickshell -p qml/shell.qml` 30s soak  | exit 124 (timeout), "Configuration Loaded", no warnings, no errors |

`build/smoke.log` holds the decoded 30s soak; `build/ipc-roundtrip.log`
holds the IPC round-trip transcript.

## Known gaps

1. `internal/pam/pam.go` links against system libpam at build time; on a
   machine without `pam-devel` headers the build fails. The headers are
   present on this machine (`/usr/include/security/pam_appl.h`).
2. `Hyprland.focusedWindowTitle` is read from
   `Hyprland.focusedMonitor.activeWorkspace.lastIpcObject.title`; if
   your Hyprland version exposes this under a different property the
   top bar's centre label will be blank.
3. Smoke ran against the live Wayland session (WAYLAND_DISPLAY is set);
   the scripted fallback to nested Hyprland or dbus-run-session was not
   exercised. Weston is not installed on this host.
4. No files were placed outside `~/code/arch-quickshell-shell`. DMS
   config was not touched.

## Re-verify

```
make all      # build + vet + lint
make ipc-test # aqs ipc status round trip
make smoke    # 30s quickshell render soak
```
