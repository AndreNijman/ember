import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: (label.text || "").length > 0
    implicitHeight: Theme.barH

    Text {
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 320)
        text: HyprlandService.focusedWindowTitle || ""
        elide: Text.ElideRight
        maximumLineCount: 1
        color: Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
