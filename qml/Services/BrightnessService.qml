pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  BrightnessService shells to `brightnessctl` (no root required for
    //  backlight on Arch with udev rules). Value in [0,1]. Kept minimal;
    //  hotplug events are not wired. The ControlCenter.Display panel
    //  polls get() when open.
    property real value: 1.0
    property bool available: true

    function refresh() {
        _get.running = true
    }
    function set(v) {
        var clamped = Math.max(0, Math.min(1, v))
        root.value = clamped
        _set.command = ["brightnessctl", "s", Math.round(clamped * 100) + "%"]
        _set.running = true
    }

    property Process _get: Process {
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = (this.text || "").trim()
                var parts = line.split(",")
                if (parts.length >= 4) {
                    var cur = parseInt(parts[2])
                    var max = parseInt(parts[4])
                    if (max > 0) root.value = cur / max
                }
            }
        }
    }
    property Process _set: Process {
        command: ["true"]
    }
    Component.onCompleted: _get.running = true
}
