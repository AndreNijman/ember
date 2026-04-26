import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
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
        color: hover.hovered ? Theme.brandHover : Theme.brand
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.weight: Font.Bold
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
    }

    Atoms.Hover {
        id: hover
        anchors.fill: parent
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) Ipc.togglePowerMenu()
            else Ipc.toggleSettings()
        }
    }
}
