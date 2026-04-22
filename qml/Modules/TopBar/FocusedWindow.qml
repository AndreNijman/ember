import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    property alias text: label.text
    visible: (label.text || "").length > 0
    implicitHeight: Theme.barH

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        text: HyprlandService.focusedWindowTitle || ""
        elide: Text.ElideRight
        maximumLineCount: 1
        horizontalAlignment: Text.AlignLeft
        color: Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
