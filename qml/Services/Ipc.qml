pragma Singleton
import QtQuick

QtObject {
    id: root
    //  Ipc: signal bus. IpcHandler objects live under ShellRoot
    //  (shell.qml) and call into these signals. Modules respond via
    //  Connections { target: Ipc }.

    signal toggleLauncher()
    signal showLauncher()
    signal hideLauncher()

    signal toggleControl()
    signal showControl()
    signal hideControl()

    signal toggleNotifications()
    signal clearNotifications()
    signal setDnd(bool v)

    signal lockEngage()

    signal osdVolume(real v)
    signal osdBrightness(real v)

    signal setWallpaper(string output, string path)
    signal workspaceFocus(int id)

    signal barShow()
    signal barHide()
    signal barToggle()

    signal toggleKeybinds()
    signal showKeybinds()
    signal hideKeybinds()

    signal toggleWallpaper()
    signal showWallpaper()
    signal hideWallpaper()

    signal toggleVpn()
    signal showVpn()
    signal hideVpn()
    signal vpnConnect()
    signal vpnDisconnect()
    signal vpnForceStop()

    function status() {
        return JSON.stringify({
            version: { major: 0, minor: 1, patch: 0 },
            pid:     Qt.application ? 0 : 0,
            socket:  "quickshell-ipc",
            backend: "qml"
        })
    }
}
