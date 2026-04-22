pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  PowerProfileService wraps power-profiles-daemon via powerprofilesctl.
    //  Exposes active profile + setter. Polls every 5s for external changes.
    property string active: "balanced"
    readonly property var profiles: ["power-saver", "balanced", "performance"]

    function set(name) {
        if (!profiles.includes(name)) return
        _set.command = ["powerprofilesctl", "set", name]
        _set.running = true
        root.active = name
    }

    function refresh() { _get.running = true }

    property Process _get: Process {
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = (this.text || "").trim()
                if (v.length > 0) root.active = v
            }
        }
    }
    property Process _set: Process { command: ["true"] }

    property Timer _poll: Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: _get.running = true
}
