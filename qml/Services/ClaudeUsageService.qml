pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool valid: false
    property real hour5Pct: 0
    property int  hour5ResetMins: 0
    property real weekPct: 0
    property int  weekResetMins: 0

    readonly property string hour5ResetLabel: _fmt(hour5ResetMins)
    readonly property string weekResetLabel:  _fmt(weekResetMins)

    function _fmt(mins) {
        if (mins <= 0) return "—"
        if (mins < 60) return mins + "m"
        var h = Math.floor(mins / 60)
        var m = mins % 60
        if (h < 24) return h + "h" + (m > 0 ? m + "m" : "")
        var d = Math.floor(h / 24)
        var rh = h % 24
        return d + "d" + (rh > 0 ? rh + "h" : "")
    }

    // Resolve script path relative to this QML file — project-root agnostic
    readonly property string _script: Qt.resolvedUrl("").replace("file://", "")
        .replace(/\/qml\/Services\/$/, "") + "/scripts/claude-usage.sh"

    function _refresh() {
        if (_proc.running) return
        _proc.running = true
    }

    property Process _proc: Process {
        property string _buf: ""
        command: ["bash", root._script]
        stdout: StdioCollector {
            onStreamFinished: { _proc._buf = this.text || "" }
        }
        onRunningChanged: if (running) _buf = ""
        onExited: {
            try {
                var d = JSON.parse(_proc._buf.trim())
                root.valid          = d.valid === true
                root.hour5Pct       = d.hour5Pct       || 0
                root.hour5ResetMins = d.hour5ResetMins  || 0
                root.weekPct        = d.weekPct         || 0
                root.weekResetMins  = d.weekResetMins   || 0
            } catch (e) {
                root.valid = false
            }
        }
    }

    property Timer _tick: Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._refresh()
    }
}
