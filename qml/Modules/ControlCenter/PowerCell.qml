import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string label: ""
    property bool danger: false
    property bool holdConfirm: false
    signal activated()

    implicitHeight: Theme.tap
    color: hover.containsMouse ? Theme.ink2 : Theme.ink1
    border.width: Theme.hairW
    border.color: hover.containsMouse ? (root.danger ? Theme.err : Theme.accent) : Theme.hair
    antialiasing: false

    Rectangle {
        id: holdFill
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 0
        color: root.danger ? Theme.err : Theme.accent
        opacity: 0.3
        antialiasing: false
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: hover.containsMouse ? (root.danger ? Theme.err : Theme.accent) : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }

    Timer {
        id: holdTimer
        interval: 33
        repeat: true
        property real elapsed: 0
        onTriggered: {
            elapsed += interval
            holdFill.width = root.width * Math.min(1, elapsed / 2000)
            if (elapsed >= 2000) {
                stop()
                elapsed = 0
                holdFill.width = 0
                root.activated()
            }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (root.holdConfirm) {
                holdTimer.elapsed = 0
                holdTimer.start()
            }
        }
        onReleased: {
            if (root.holdConfirm) {
                holdTimer.stop()
                holdTimer.elapsed = 0
                holdFill.width = 0
            }
        }
        onClicked: {
            if (!root.holdConfirm) root.activated()
        }
    }
}
