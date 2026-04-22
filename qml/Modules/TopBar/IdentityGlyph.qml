import QtQuick
import "../../Theme"

Item {
    id: root
    //  IdentityGlyph: small label at the bar's left edge. The brand mark.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: "aqs"
        color: Theme.accent
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.weight: Font.Bold
    }
}
