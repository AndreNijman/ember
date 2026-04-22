import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string label: ""
    property bool danger: false
    signal activated()

    implicitHeight: Theme.tap
    color: hover.containsMouse ? Theme.ink2 : Theme.ink1
    border.width: Theme.hairW
    border.color: hover.containsMouse ? (root.danger ? Theme.err : Theme.accent) : Theme.hair
    antialiasing: false

    Text {
        anchors.centerIn: parent
        text: root.label
        color: hover.containsMouse ? (root.danger ? Theme.err : Theme.accent) : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
