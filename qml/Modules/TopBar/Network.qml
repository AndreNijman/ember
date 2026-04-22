import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            if (!NetworkService.online) {
                if (NetworkService.kind === "none") return "wifi · —"
                return "wifi · off"
            }
            if (NetworkService.kind === "wifi")
                return "wifi · " + (NetworkService.ssid || "—")
            if (NetworkService.kind === "ethernet") return "eth"
            return "—"
        }
        color: NetworkService.online ? Theme.ink7 : Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
