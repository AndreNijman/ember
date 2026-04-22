pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  CalcService pipes a query through `qalc -t -s "unicode off"` and
    //  exposes the most recent result string. The Launcher's CalcStrip
    //  binds to `result` and `busy`.
    property string query: ""
    property string result: ""
    property bool busy: false

    onQueryChanged: _run()

    function _run() {
        if (!query || query.length === 0) { result = ""; return }
        busy = true
        _p.command = ["qalc", "-t", "-s", "unicode off", query]
        _p.running = true
    }

    property Process _p: Process {
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.result = (this.text || "").trim()
                root.busy = false
            }
        }
    }
}
