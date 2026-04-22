pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  NetworkService exposes a minimal NetworkManager view via `nmcli -t`.
    //  Full dbus NM integration is deferred; the surface/props that the
    //  shell's Network composite + ControlCenter.Network panel touch are
    //  present. Events are polled on a 4s timer + on explicit refresh.
    property string ssid: ""
    property int strength: 0
    property string kind: "none"  // wifi | ethernet | none
    property bool online: false
    property string vpnIface: ""

    signal toggled(bool on)

    function refresh() { _dev.running = true }
    function connectWifi(ssid, password) {
        _conn.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
        _conn.running = true
    }

    property Process _dev: Process {
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "dev", "status"]
        stdout: StdioCollector {
            onStreamFinished: root._parseDev(this.text || "")
        }
    }
    property Process _conn: Process { command: ["true"] }
    property Timer _timer: Timer {
        interval: 4000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    function _parseDev(out) {
        var lines = out.split("\n")
        var best = null
        var vpn = ""
        for (var i = 0; i < lines.length; i++) {
            var cols = lines[i].split(":")
            if (cols.length < 4) continue
            if (cols[2] !== "connected") continue
            if (cols[1] === "tun" || cols[1] === "wireguard") {
                vpn = cols[0]
            } else if (cols[1] === "wifi" || cols[1] === "ethernet") {
                best = { type: cols[1], conn: cols[3] }
                if (cols[1] === "wifi") break
            }
        }
        root.vpnIface = vpn
        if (best) {
            root.kind = best.type
            root.ssid = best.conn
            root.online = true
            root.strength = best.type === "wifi" ? 75 : 100
        } else {
            root.kind = "none"
            root.ssid = ""
            root.online = false
            root.strength = 0
        }
    }
}
