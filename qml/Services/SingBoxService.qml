pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string state: "off" // off | connecting | checking | on | degraded | disconnecting
    property string egressIp: ""
    property int latencyMs: 0
    property real rxBytes: 0
    property real txBytes: 0
    property real rxRate: 0
    property real txRate: 0
    property string speedResult: ""
    property bool speedRunning: false

    readonly property bool active: state === "on" || state === "checking" || state === "degraded"
    readonly property bool busy: state === "connecting" || state === "disconnecting"

    function toggle() {
        if (busy) return
        if (state === "off") {
            state = "connecting"
            _start.running = true
        } else {
            state = "disconnecting"
            _stop.running = true
        }
    }

    function runSpeedtest() {
        if (speedRunning) return
        speedRunning = true
        speedResult = ""
        _speed.running = true
    }

    property real _prevRx: 0
    property real _prevTx: 0

    property Process _statusCheck: Process {
        command: ["systemctl", "is-active", "sing-box"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (this.text || "").trim()
                if (out === "active") {
                    if (root.state === "off" || root.state === "connecting")
                        root.state = "checking"
                    if (root.state === "checking" && root.egressIp.length > 0)
                        root.state = "on"
                } else {
                    if (root.state !== "connecting")
                        root.state = "off"
                    root.egressIp = ""
                    root.latencyMs = 0
                    root.rxRate = 0
                    root.txRate = 0
                }
            }
        }
    }

    property Process _start: Process {
        command: ["sudo", "-n", "systemctl", "start", "sing-box.service"]
        onExited: (code) => {
            if (code === 0) root.state = "checking"
            else root.state = "off"
        }
    }

    property Process _stop: Process {
        command: ["sudo", "-n", "systemctl", "stop", "sing-box.service"]
        onExited: { root.state = "off"; root.egressIp = ""; root.rxRate = 0; root.txRate = 0 }
    }

    property Process _egressCheck: Process {
        command: ["timeout", "6", "curl", "--max-time", "4", "-s", "https://api.ipify.org"]
        stdout: StdioCollector {
            onStreamFinished: {
                var ip = (this.text || "").trim()
                if (ip.length > 0 && ip.indexOf(".") > 0) {
                    root.egressIp = ip
                    if (root.state === "checking") root.state = "on"
                } else if (root.state === "on") {
                    root.state = "degraded"
                }
            }
        }
        onExited: (code) => {
            if (code !== 0 && root.active) root.state = "degraded"
        }
    }

    property Process _latencyCheck: Process {
        command: ["timeout", "6", "curl", "--max-time", "4", "-s", "-o", "/dev/null", "-w", "%{time_total}", "https://1.1.1.1/cdn-cgi/trace"]
        stdout: StdioCollector {
            onStreamFinished: {
                var ms = Math.round(parseFloat(this.text || "0") * 1000)
                if (ms > 0) root.latencyMs = ms
            }
        }
    }

    property Process _byteCheck: Process {
        command: ["sh", "-c", "cat /sys/class/net/sb-tun/statistics/rx_bytes /sys/class/net/sb-tun/statistics/tx_bytes 2>/dev/null || echo '0\n0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (this.text || "").trim().split("\n")
                var rx = parseFloat(lines[0] || "0")
                var tx = parseFloat(lines[1] || "0")
                if (root._prevRx > 0) {
                    root.rxRate = rx - root._prevRx
                    root.txRate = tx - root._prevTx
                }
                root._prevRx = rx
                root._prevTx = tx
                root.rxBytes = rx
                root.txBytes = tx
            }
        }
    }

    property Process _speed: Process {
        command: ["timeout", "75", "speedtest", "--json", "--secure"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.speedRunning = false
                try {
                    var j = JSON.parse(this.text || "{}")
                    var dl = (j.download / 1e6).toFixed(1)
                    var ul = (j.upload / 1e6).toFixed(1)
                    var ping = Math.round(j.ping)
                    root.speedResult = "↓" + dl + "  ↑" + ul + "  " + ping + "ms"
                } catch(e) {
                    root.speedResult = "error"
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) { root.speedRunning = false; root.speedResult = "error" }
        }
    }

    property Timer _statusTimer: Timer {
        interval: 3000; repeat: true; running: true
        onTriggered: root._statusCheck.running = true
    }
    property Timer _byteTimer: Timer {
        interval: 1000; repeat: true; running: root.active
        onTriggered: root._byteCheck.running = true
    }
    property Timer _egressTimer: Timer {
        interval: 15000; repeat: true; running: root.active
        onTriggered: { root._egressCheck.running = true; root._latencyCheck.running = true }
    }

    Component.onCompleted: _statusCheck.running = true

    function formatBytes(b) {
        if (b < 1024) return b.toFixed(0) + " B"
        if (b < 1048576) return (b / 1024).toFixed(1) + " KB"
        if (b < 1073741824) return (b / 1048576).toFixed(1) + " MB"
        return (b / 1073741824).toFixed(2) + " GB"
    }
    function formatRate(bps) {
        if (bps < 1024) return bps.toFixed(0) + " B/s"
        if (bps < 1048576) return (bps / 1024).toFixed(0) + " KB/s"
        return (bps / 1048576).toFixed(1) + " MB/s"
    }
}
