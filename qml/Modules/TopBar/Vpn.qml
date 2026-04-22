import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  Vpn bar pill: compact status + click target. Monochrome when off,
    //  amber when tunnel up + egress verified, err when degraded. Click
    //  toggles the VPN popout via Ipc.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    signal clicked()

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            const s = VpnService.state
            if (s === "on")             return "vpn vps"
            if (s === "degraded")       return "vpn!"
            if (s === "connecting")     return "vpn…"
            if (s === "checking")       return "vpn…"
            if (s === "disconnecting")  return "vpn…"
            return "vpn"
        }
        color: {
            const s = VpnService.state
            if (s === "on")       return Theme.accent
            if (s === "degraded") return Theme.err
            if (s === "off")      return Theme.ink5
            return Theme.warn
        }
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
