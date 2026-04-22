pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  LockService tracks the lock surface's visibility and authenticates
    //  via the `aqs pam authenticate` subcommand. It does not actually
    //  take the wayland session lock here; the Lock/ module owns that
    //  window and flips `locked` through this service.
    property bool locked: false
    property bool authenticating: false
    property string lastError: ""

    signal unlocked()
    signal authFailed(string msg)

    function lock() { root.locked = true }
    function submit(password) {
        if (root.authenticating) return
        root.authenticating = true
        _auth.stdinEnabled = true
        _auth.running = true
        _auth.write(password + "\n")
        _auth.closeStdin()
    }

    property Process _auth: Process {
        command: ["aqs", "pam", "authenticate"]
        stdinEnabled: false
        onExited: (code, status) => {
            root.authenticating = false
            if (code === 0) {
                root.lastError = ""
                root.locked = false
                root.unlocked()
            } else {
                root.lastError = "authentication failed"
                root.authFailed(root.lastError)
            }
        }
    }
}
