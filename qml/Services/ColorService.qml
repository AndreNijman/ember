pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var history: []
    property string _path: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/aqs/colors.json"

    signal picked(string hex)

    function _load() { _file.reload() }

    property FileView _file: FileView {
        path: root._path
        blockLoading: false
        onLoaded: {
            try {
                var arr = JSON.parse(this.text())
                if (Array.isArray(arr)) root.history = arr.slice(0, 16)
            } catch (e) { /* fresh */ }
        }
        onLoadFailed: root.history = []
    }

    property Process _writer: Process {}

    function _save() {
        var body = JSON.stringify(root.history, null, 2)
        _writer.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$AQS_PATH\")\" && printf '%s' \"$AQS_BODY\" > \"$AQS_PATH\""]
        _writer.environment = ({ "AQS_PATH": root._path, "AQS_BODY": body })
        _writer.running = true
    }

    function append(hex) {
        if (!hex || hex.length === 0) return
        var cleaned = hex.trim().toLowerCase()
        if (cleaned[0] !== "#") cleaned = "#" + cleaned
        var next = [cleaned]
        for (var i = 0; i < root.history.length; i++) {
            if (root.history[i].toLowerCase() !== cleaned) next.push(root.history[i])
            if (next.length >= 16) break
        }
        root.history = next
        root._save()
        root.picked(cleaned)
    }

    function clear() {
        root.history = []
        root._save()
    }

    property Process _picker: Process {
        property string _out: ""
        command: ["hyprpicker", "-a", "-f", "hex"]
        onRunningChanged: if (running) _out = ""
        stdout: SplitParser {
            onRead: (line) => { _picker._out = line.trim() }
        }
        onExited: if (_out.length > 0) root.append(_out)
    }

    function pick() { _picker.running = true }

    Component.onCompleted: _load()
}
