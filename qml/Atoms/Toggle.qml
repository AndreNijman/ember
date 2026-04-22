import QtQuick
import "../Theme"

Rectangle {
    id: root
    //  Toggle: hard-cut on/off pill. No animation on width, only fill color
    //  and inner 1px hairline flip.
    property bool on: false
    signal toggled(bool value)

    implicitWidth: 36
    implicitHeight: 18
    color: on ? Theme.accent : Theme.ink2
    border.color: on ? Theme.accent : Theme.hair
    border.width: Theme.hairW
    antialiasing: false
    radius: 0

    Rectangle {
        width: 8; height: 8
        x: root.on ? root.width - width - 4 : 4
        y: (parent.height - height) / 2
        color: root.on ? Theme.accentFg : Theme.ink7
        antialiasing: false
        Behavior on x { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.on = !root.on
            root.toggled(root.on)
        }
    }
}
