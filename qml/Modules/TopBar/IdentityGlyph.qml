import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  IdentityGlyph: brand mark + settings entry point.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: "Ember"
        color: hover.containsMouse ? Theme.ink8 : Theme.accent
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.weight: Font.Bold
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) Ipc.togglePowerMenu()
            else Ipc.toggleSettings()
        }
    }
}
