pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real cpuPct: 0
    property real memPct: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real netRxBps: 0
    property real netTxBps: 0
    property string netIface: ""

    property var _prevCpu: ({ idle: 0, total: 0 })
    property var _prevNet: ({ rx: 0, tx: 0, t: 0 })

    function _readFile(path, cb) {
        _reader.path = path
        _reader._cb = cb
        _reader._lines = []
        _reader.running = true
    }

    property Process _reader: Process {
        property string path: ""
        property var _cb: null
        property var _lines: []
        command: ["cat", path]
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _reader._lines.push(line) }
        }
        onExited: if (_cb) _cb(_lines)
    }

    function _refreshCpu() {
        _readFile("/proc/stat", (lines) => {
            if (lines.length === 0) return
            var parts = lines[0].split(/\s+/)
            if (parts[0] !== "cpu") return
            var user = parseInt(parts[1]) || 0
            var nice = parseInt(parts[2]) || 0
            var sys = parseInt(parts[3]) || 0
            var idle = parseInt(parts[4]) || 0
            var iowait = parseInt(parts[5]) || 0
            var irq = parseInt(parts[6]) || 0
            var softirq = parseInt(parts[7]) || 0
            var steal = parseInt(parts[8]) || 0
            var idleAll = idle + iowait
            var nonIdle = user + nice + sys + irq + softirq + steal
            var total = idleAll + nonIdle
            var dTotal = total - root._prevCpu.total
            var dIdle = idleAll - root._prevCpu.idle
            if (dTotal > 0) root.cpuPct = (1 - dIdle / dTotal) * 100
            root._prevCpu = { idle: idleAll, total: total }
        })
    }

    function _refreshMem() {
        _readMem.running = true
    }

    property Process _readMem: Process {
        property var _lines: []
        command: ["cat", "/proc/meminfo"]
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _readMem._lines.push(line) }
        }
        onExited: {
            var total = 0, avail = 0
            for (var i = 0; i < _lines.length; i++) {
                var L = _lines[i]
                if (L.indexOf("MemTotal:") === 0) total = parseInt(L.replace(/[^0-9]/g, ""))
                else if (L.indexOf("MemAvailable:") === 0) avail = parseInt(L.replace(/[^0-9]/g, ""))
            }
            if (total > 0) {
                root.memPct = (1 - avail / total) * 100
                root.memTotalGb = total / 1024 / 1024
                root.memUsedGb = (total - avail) / 1024 / 1024
            }
        }
    }

    function _refreshNet() {
        _readNet.running = true
    }

    property Process _readNet: Process {
        property var _lines: []
        command: ["sh", "-c", "cat /proc/net/dev"]
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _readNet._lines.push(line) }
        }
        onExited: {
            var rx = 0, tx = 0, iface = ""
            for (var i = 0; i < _lines.length; i++) {
                var L = _lines[i].trim()
                var m = L.match(/^([a-zA-Z0-9_-]+):\s+(\d+)(?:\s+\d+){7}\s+(\d+)/)
                if (!m) continue
                var name = m[1]
                if (name === "lo" || name.indexOf("sb-") === 0 || name.indexOf("docker") === 0 || name.indexOf("veth") === 0 || name.indexOf("br-") === 0) continue
                var r = parseInt(m[2])
                var t = parseInt(m[3])
                rx += r
                tx += t
                if (r + t > 0 && iface === "") iface = name
            }
            var now = Date.now() / 1000
            var dt = now - root._prevNet.t
            if (root._prevNet.t > 0 && dt > 0) {
                root.netRxBps = Math.max(0, (rx - root._prevNet.rx) / dt)
                root.netTxBps = Math.max(0, (tx - root._prevNet.tx) / dt)
            }
            root._prevNet = { rx: rx, tx: tx, t: now }
            root.netIface = iface
        }
    }

    function formatRate(bps) {
        if (bps < 1024) return Math.round(bps) + "B"
        if (bps < 1024 * 1024) return (bps / 1024).toFixed(0) + "K"
        if (bps < 1024 * 1024 * 1024) return (bps / 1024 / 1024).toFixed(1) + "M"
        return (bps / 1024 / 1024 / 1024).toFixed(2) + "G"
    }

    property Timer _tick: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._refreshCpu()
            root._refreshMem()
            root._refreshNet()
        }
    }
}
