import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: NetworkService.vpnIface.length > 0
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: "vpn · " + NetworkService.vpnIface
        color: Theme.ok
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
