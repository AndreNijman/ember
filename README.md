# ember

A Quickshell + Go desktop shell for Hyprland on Arch Linux. Sharp-edged,
monochrome aesthetic — 1px hairlines, no rounded corners, single accent
color, no blur or shadow.

The CLI binary is `aqs`; the greeter binary is `aqs-greeter`.

## Features

- **Bar** — workspaces, focused window, clock, MPRIS now-playing, system
  tray, CPU / RAM / network throughput pills, VPN, network, volume, battery
- **Launcher** (`Alt+Space`) — apps + `=` calc + `>` shell + `:` window
  switcher + `?` clipboard
- **Control center** (`Super+K`) — Wi-Fi (with WPA password prompt),
  Bluetooth (scan + pair + forget + connect), audio in/out + per-app mixer,
  brightness, power profiles, DND, idle inhibitor, power row
- **Notification center** (`Super+N`) — toasts + history, grouping, DND,
  survives shell reload
- **Lock screen** (`Super+L`) — wayland session-lock, PAM auth, capslock detect
- **Greeter** — `aqs-greeter` integrates with greetd, themed to match
- **OSD** — volume, brightness, mic-mute on key presses
- **Clipboard** (`Super+V`) — cliphist-backed history with image previews
- **Wallpaper picker** (`Super+B`) — thumbnails grid, per-workspace assign
- **Calendar** — gcalcli agenda + inline event creation
- **Overview** (`Super+Tab`) — workspace/window grid
- **Settings** (`aqs ipc settings open`) — `~/.config/aqs/settings.json`
  backed configuration UI
- **Power menu** (`aqs ipc powermenu open`) — full-screen lock / logout /
  suspend / reboot / shutdown
- **Cheat sheet** (`Super+/`) — parses your `~/.config/hypr/aqs/binds.conf`
- **SingBox VPN** panel — for the original author's tunnel; remove if not used

## Install

### Arch (AUR)

```sh
paru -S ember           # or yay -S ember
systemctl --user enable --now aqs.service
```

### From source

```sh
git clone https://github.com/AndreNijman/ember.git
cd ember
make all
sudo make install                   # installs to /usr/local
systemctl --user enable --now aqs.service
```

### First-run config

Copy the starter Hyprland config in if you don't already have one:

```sh
mkdir -p ~/.config/hypr/aqs
cp /usr/local/share/aqs/contrib/hypr/hyprland.conf.example  ~/.config/hypr/hyprland.conf
cp /usr/local/share/aqs/contrib/hypr/aqs/binds.conf         ~/.config/hypr/aqs/binds.conf
```

Then enable the cliphist watcher so the clipboard panel sees new copies:

```sh
systemctl --user enable --now cliphist.service
```

### Greeter (optional)

```sh
sudo /usr/local/share/aqs/scripts/install-greeter.sh
```

This swaps `/etc/greetd/config.toml` to launch `aqs-greeter`. Backups of
the previous config are saved with a `.bak-pre-aqs-<timestamp>` suffix.
Revert with `--uninstall`.

## Requirements

| Component               | Why                                        |
|-------------------------|--------------------------------------------|
| `hyprland`              | Compositor                                  |
| `quickshell-git` 0.2.1+ | UI runtime                                  |
| `pipewire`, `wireplumber` | Audio                                     |
| `networkmanager`        | Wi-Fi                                       |
| `bluez`, `bluez-utils`  | Bluetooth                                   |
| `brightnessctl`         | Backlight                                   |
| `cliphist`, `wl-clipboard` | Clipboard                                |
| `playerctl`             | Media keys                                  |
| `qalculate-gtk`         | Launcher `=` calc mode                      |
| `gcalcli`               | Calendar agenda + add                       |
| `hyprshot`, `hyprpicker` | Screenshot + color picker keybinds         |
| `greetd` + `start-hyprland` | Greeter (optional)                      |

Build deps: `go 1.21+`, `scdoc` (manpage), PAM headers.

## IPC

```
aqs ipc shell version
aqs ipc launcher       toggle | show | hide
aqs ipc control        toggle | show | hide
aqs ipc notifications  toggle | clearAll | setDnd <true|false>
aqs ipc lock           engage
aqs ipc audio          mute | micmute | increment <n> | decrement <n>
aqs ipc brightness     increment <n> | decrement <n>
aqs ipc workspace      focus <id>
aqs ipc wallpaper      toggle | show | hide | setForWorkspace <ws> <path> | setAll <path>
aqs ipc clipboard      toggle | show | hide
aqs ipc keybinds       toggle | show | hide
aqs ipc overview       toggle | show | hide
aqs ipc singbox        toggle | show | hide | connect
aqs ipc powermenu      toggle | show | hide
aqs ipc settings       toggle | show | hide | open | set <key> <value>
```

`man aqs` after install for the full reference.

## Configuration

`~/.config/aqs/settings.json` — written by the in-shell Settings panel,
hand-editable for fields not yet exposed in the UI:

```json
{
  "dpmsTimeoutSec": 180,
  "lockTimeoutSec": 300,
  "dndDefault": false,
  "barShowCpu": true,
  "barShowRam": true,
  "barShowNet": true,
  "barShowVpn": true
}
```

## Troubleshooting

- **No notifications appear** — another notification daemon (mako, dunst,
  swaync) is holding `org.freedesktop.Notifications`. Stop and disable it.
- **Clipboard panel empty** — `systemctl --user enable --now cliphist.service`.
  For images, also run `wl-paste --type image --watch cliphist store`.
- **WiFi password modal does nothing** — check that `nmcli` works on its
  own (`nmcli dev wifi connect SSID password XXX`).
- **Greeter loops on restart** — `journalctl -u greetd -n 100` and
  `cat /tmp/aqs-greeter.log`. The most common cause is a missing helper
  binary (`start-hyprland`, `quickshell`).
- **Bar pills missing after upgrade** — Settings panel → toggle the
  show* options, or edit `~/.config/aqs/settings.json` directly.

## Hacking

See [`docs/HACKING.md`](docs/HACKING.md) for the layout of the QML tree,
service architecture, and how to add a new module.

## License

MIT — see [LICENSE](LICENSE).
