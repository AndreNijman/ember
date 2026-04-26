# HACKING

Developer notes. End-user docs live in [`README.md`](../README.md).

## Layout

```
cmd/
  aqs/             Go CLI: `aqs ipc <target> <action>` + `aqs pam` helper
  aqs-greeter/     Greetd greeter: spawns Hyprland + mediates auth
internal/
  ipc/             IPC client (qs ipc call wrapper)
  pam/             PAM auth via stdin (used by LockService)
  proto/           protocol version + message types
  socket/          Unix socket helpers for the qs IPC bridge
qml/
  shell.qml        ShellRoot entry, IpcHandler bindings
  Theme/           Tokens / Theme / Fonts singletons (no other module
                   may hold literal colors, sizes, or durations)
  Atoms/           13 primitives (Hairline, Slider, Field, Toggle, ...)
  Services/        Singletons for backends (Hyprland, Audio, Network,
                   Bluetooth, Settings, Idle, Lock, Notifications, ...)
  Modules/         Per-surface trees (TopBar, Launcher, ControlCenter,
                   NotificationCenter, OSD, Lock, Settings, PowerMenu,
                   WallpaperManager, Clipboard, Keybinds, Calendar,
                   Overview, SingBox)
  greeter.qml      Standalone QML loaded by aqs-greeter (NOT shell.qml)
contrib/
  hypr/            Starter Hyprland config + binds
  greetd/          config.toml.example
  systemd/         aqs.service (PartOf graphical-session.target)
  pkg/aur/         PKGBUILD
scripts/
  install-greeter.sh   Backed-up swap of /etc/greetd/config.toml
  smoke.sh             30s quickshell render soak
  ipc-roundtrip.sh     IPC stub round-trip
docs/
  HACKING.md       this file
  aqs.1.scd        scdoc source for man aqs(1)
```

## Build

```sh
make all          # go build + vet + qmllint
make build        # binaries → build/aqs, build/aqs-greeter
make man          # scdoc → build/aqs.1
make smoke        # 30s render check (requires running session)
make ipc-test     # round-trip aqs ipc against stub
```

`make build` injects `git describe --tags --always --dirty` into
`main.version` via `-ldflags -X`. `aqs ipc shell version` reflects it.

## Adding a service

1. New file in `qml/Services/<Name>Service.qml`, `pragma Singleton`,
   `QtObject` root.
2. Register in `qml/Services/qmldir`.
3. If it polls or writes settings, add the relevant fields to
   `SettingsService.qml` and read them from there instead of hardcoding.

## Adding a module

1. New directory `qml/Modules/<Name>/<Name>.qml`, `PanelWindow` root with
   `WlrLayershell.namespace = "aqs-<lowercase>"`.
2. Add a `qmldir` exposing the type.
3. Import + instantiate in `qml/shell.qml`.
4. Add IPC: signal in `qml/Services/Ipc.qml`, handler in `shell.qml`,
   match the existing target/action shape.
5. Lint: `qmllint -I qml -I /usr/lib/qt6/qml qml/Modules/<Name>/*.qml`.

## Service status (legacy BUILD_NOTES)

The historical `BUILD_NOTES.md` matrix is being phased out. Any
remaining stubs should be tracked as GitHub issues, not as comments.

## Greeter dev

`aqs-greeter` requires `$GREETD_SOCK` to run, so it cannot be started
standalone from a normal shell. Test via `scripts/install-greeter.sh`
on a throwaway VT, or run it under a mocked greetd.

The QML side (`qml/greeter.qml`) talks to the binary over a Unix socket
exposed via `$AQS_GREETER_SOCK`. Wire protocol is newline-delimited:

```
QML  -> auth <user> <password>
QML  -> start
QML  -> power off|reboot
bin  -> ok
bin  -> err <message>
bin  -> prompt <message>
```

## Versioning

Tag `vX.Y.Z` releases on `main`. PKGBUILD pulls the tag. CI must pass
on the tagged SHA before tagging.
