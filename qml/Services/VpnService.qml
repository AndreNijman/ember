pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    //  VpnService: sing-box VLESS+REALITY tunnel to Vultr Sydney VPS.
    //  State machine: off -> connecting -> checking -> on|degraded -> disconnecting -> off.
    //  `degraded` = service up but egress IP != VPS IP (half-up tunnel).
    //  All probes timeout-wrapped so a half-up tunnel never hangs the UI.
    //
    //  Requires: passwordless sudo for `systemctl start|stop|restart sing-box.service`.
    //  Tunnel iface is `sb-tun`; egress checked via CF trace (1.1.1.1/cdn-cgi/trace).

    readonly property string vpsIp: "VPN_HOST"
    readonly property int statePollMs: 3000
    readonly property int ifacePollMs: 1000
    readonly property int egressPollMs: 15000

    property string state: "off"
    property bool serviceActive: false
    property string egressIp: ""
    property int latencyMs: -1
    property real rxBytes: 0
    property real txBytes: 0
    property real prevRx: 0
    property real prevTx: 0
    property real rxRate: 0
    property real txRate: 0
    property string lastError: ""

    function toggle() {
        if (root.state === "connecting" || root.state === "disconnecting" || root.state === "checking") return
        if (root.state === "off") {
            root.state = "connecting"
            root.lastError = ""
            _startProc.running = true
        } else if (root.state === "degraded") {
            root.state = "connecting"
            _restartProc.running = true
        } else {
            root.state = "disconnecting"
            _stopProc.running = true
        }
    }

    //  Force-quit: hard stop regardless of current state. For when the tunnel
    //  is wedged in connecting/checking/disconnecting or a degraded loop.
    //  Fires stop unconditionally and snaps UI to "off" without waiting for
    //  the 3s state poll.
    function forceStop() {
        root.lastError = "force-stopped"
        root.state = "off"
        root.serviceActive = false
        root.egressIp = ""
        root.latencyMs = -1
        root.rxRate = 0
        root.txRate = 0
        root.prevRx = 0
        root.prevTx = 0
        if (_startProc.running)   _startProc.running = false
        if (_restartProc.running) _restartProc.running = false
        if (_egressProc.running)  _egressProc.running = false
        _stopProc.running = true
    }

    function refresh() {
        if (!_stateProc.running) _stateProc.running = true
        if (root.serviceActive) _checkEgress()
    }

    function _checkEgress() {
        if (!root.serviceActive) return
        if (_egressProc.running) return
        _egressProc.running = true
    }

    function _pollIface() {
        if (!root.serviceActive) { root.rxRate = 0; root.txRate = 0; return }
        if (_ifaceProc.running) return
        _ifaceProc.running = true
    }

    property Process _stateProc: Process {
        command: ["systemctl", "is-active", "sing-box.service"]
        stdout: StdioCollector {
            onStreamFinished: {
                const wasActive = root.serviceActive
                root.serviceActive = (text || "").trim() === "active"
                if (root.serviceActive && !wasActive) {
                    if (root.state !== "connecting") root.state = "checking"
                    Qt.callLater(() => root._checkEgress())
                } else if (!root.serviceActive && wasActive) {
                    root.state = "off"
                    root.egressIp = ""
                    root.latencyMs = -1
                    root.rxRate = 0
                    root.txRate = 0
                    root.prevRx = 0
                    root.prevTx = 0
                } else if (root.serviceActive && root.state === "off") {
                    root.state = "checking"
                    Qt.callLater(() => root._checkEgress())
                }
            }
        }
    }

    property Process _startProc: Process {
        command: ["sudo", "-n", "systemctl", "start", "sing-box.service"]
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.state = "off"
                root.lastError = "start failed (exit " + exitCode + ")"
            } else {
                root.state = "checking"
                Qt.callLater(() => root._checkEgress())
            }
        }
    }

    property Process _stopProc: Process {
        command: ["sudo", "-n", "systemctl", "stop", "sing-box.service"]
        onExited: (exitCode) => {
            root.state = "off"
            root.egressIp = ""
            root.latencyMs = -1
            root.rxRate = 0
            root.txRate = 0
            root.prevRx = 0
            root.prevTx = 0
            if (exitCode !== 0) root.lastError = "stop failed (exit " + exitCode + ")"
        }
    }

    property Process _restartProc: Process {
        command: ["sudo", "-n", "systemctl", "restart", "sing-box.service"]
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.state = "off"
                root.lastError = "restart failed (exit " + exitCode + ")"
            } else {
                root.state = "checking"
                Qt.callLater(() => root._checkEgress())
            }
        }
    }

    property Process _egressProc: Process {
        //  CF trace: small payload, CF Sydney PoP = low TTFB, body carries ip=.
        //  time_starttransfer (TTFB) is closer to ping than time_total.
        //  timeout 6 + curl --max-time 4 = hard cap vs. half-up tunnel.
        command: ["bash", "-c", "timeout 6 curl --max-time 4 -s -o /tmp/.ember_cf_trace -w '%{http_code} %{time_starttransfer}\\n' https://1.1.1.1/cdn-cgi/trace; echo '---'; cat /tmp/.ember_cf_trace 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = (text || "").trim()
                const timeMatch = out.match(/200 ([\d.]+)/)
                const ipMatch = out.match(/ip=([\d.]+)/)
                if (ipMatch) {
                    root.egressIp = ipMatch[1]
                    if (timeMatch) root.latencyMs = Math.round(parseFloat(timeMatch[1]) * 1000)
                    if (root.serviceActive) {
                        root.state = (root.egressIp === root.vpsIp) ? "on" : "degraded"
                    }
                } else {
                    root.egressIp = ""
                    root.latencyMs = -1
                    if (root.serviceActive) root.state = "degraded"
                }
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.serviceActive) root.state = "degraded"
        }
    }

    property Process _ifaceProc: Process {
        command: ["bash", "-c", "cat /sys/class/net/sb-tun/statistics/rx_bytes /sys/class/net/sb-tun/statistics/tx_bytes 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = (text || "").trim().split(/\s+/)
                if (parts.length >= 2) {
                    const rx = parseFloat(parts[0])
                    const tx = parseFloat(parts[1])
                    if (root.prevRx > 0) {
                        const dt = root.ifacePollMs / 1000
                        root.rxRate = Math.max(0, (rx - root.prevRx) / dt)
                        root.txRate = Math.max(0, (tx - root.prevTx) / dt)
                    }
                    root.prevRx = rx
                    root.prevTx = tx
                    root.rxBytes = rx
                    root.txBytes = tx
                }
            }
        }
    }

    property Timer _pollState: Timer {
        interval: root.statePollMs; repeat: true; running: true; triggeredOnStart: true
        onTriggered: { if (!root._stateProc.running) root._stateProc.running = true }
    }

    property Timer _pollEgress: Timer {
        interval: root.egressPollMs; repeat: true; running: root.serviceActive
        onTriggered: root._checkEgress()
    }

    property Timer _pollIfaceT: Timer {
        interval: root.ifacePollMs; repeat: true; running: root.serviceActive
        onTriggered: root._pollIface()
    }
}
