import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string label: ""
    property bool assigned: false
    property bool wide: false
    signal picked()

    width: wide ? 44 : 28
    height: Theme.rowH - 8
    color: assigned ? Theme.ink2 : "transparent"
    border.width: assigned ? 2 : (hover.containsMouse && root.enabled ? Theme.hairW : 0)
    border.color: Theme.accent
    antialiasing: false
    opacity: root.enabled ? 1.0 : 0.4

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.assigned ? Theme.accent : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.txs
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.picked()
    }
}
