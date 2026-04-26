pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool capsLock:   false
    property bool numLock:    false
    property bool scrollLock: false

    property Process _poll: Process {
        property var _lines: []
        command: ["sh", "-c",
            "for k in capslock numlock scrolllock; do " +
            "  v=0; for f in /sys/class/leds/input*::$k/brightness; do " +
            "    [ -r \"$f\" ] && [ \"$(cat $f)\" = \"1\" ] && v=1 && break; " +
            "  done; echo \"$k=$v\"; " +
            "done"]
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _poll._lines.push(line) }
        }
        onExited: {
            for (var i = 0; i < _lines.length; i++) {
                var p = _lines[i].split("=")
                if (p.length !== 2) continue
                var on = p[1] === "1"
                switch (p[0]) {
                    case "capslock":   root.capsLock   = on; break
                    case "numlock":    root.numLock    = on; break
                    case "scrolllock": root.scrollLock = on; break
                }
            }
        }
    }

    property Timer _tick: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._poll.running = true
    }
}
