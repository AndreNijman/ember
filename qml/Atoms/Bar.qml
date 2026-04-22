import QtQuick
import "../Theme"

Item {
    id: root
    //  Bar is a linear progress/level indicator. Value in [0,1].
    property real value: 0.0
    property bool accent: true
    property int thickness: 2

    implicitHeight: thickness
    implicitWidth: 120

    Rectangle {
        anchors.fill: parent
        color: Theme.ink3
        radius: Theme.radius2
        antialiasing: false
    }
    Rectangle {
        height: parent.height
        width: parent.width * Math.max(0, Math.min(1, root.value))
        color: root.accent ? Theme.accent : Theme.ink7
        radius: Theme.radius2
        antialiasing: false
        Behavior on width { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }
}
