import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  Network composite: short status string. "WIFI" or "ETH" or "OFF".
    //  The ControlCenter.Network panel carries the SSID + signal detail.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            if (!NetworkService.online) return "off"
            if (NetworkService.kind === "wifi") return "wifi"
            if (NetworkService.kind === "ethernet") return "eth"
            return "--"
        }
        color: NetworkService.online ? Theme.ink7 : Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
