import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: SettingsService.barShowVpn
    implicitHeight: Theme.barH
    implicitWidth: visible ? label.implicitWidth + Theme.s3 * 2 : 0

    Text {
        id: label
        anchors.centerIn: parent
        text: SingBoxService.active ? "vpn" : "vpn"
        color: {
            if (SingBoxService.state === "on") return Theme.ok
            if (SingBoxService.state === "degraded") return Theme.warn
            if (SingBoxService.busy || SingBoxService.state === "checking") return Theme.accent
            return Theme.ink5
        }
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton)
                SingBoxService.toggle()
            else
                Ipc.toggleSingBox()
        }
    }
}
