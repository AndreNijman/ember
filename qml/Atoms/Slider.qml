import QtQuick
import "../Theme"

Item {
    id: root
    //  Slider: horizontal value control. Thin 2px track + square thumb.
    property real value: 0.0
    property real min_: 0.0
    property real max_: 1.0
    signal changed(real value)

    implicitHeight: Theme.rowH
    implicitWidth: 160

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 2
        color: Theme.ink3
        antialiasing: false
    }
    Rectangle {
        id: fill
        anchors.verticalCenter: parent.verticalCenter
        height: 2
        color: Theme.accent
        width: parent.width * clamped(root.value)
        antialiasing: false
    }
    Rectangle {
        id: thumb
        width: 8; height: 14
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.ink8
        border.color: Theme.hair
        border.width: Theme.hairW
        x: Math.max(0, Math.min(parent.width - width, parent.width * clamped(root.value) - width / 2))
        antialiasing: false
    }
    MouseArea {
        anchors.fill: parent
        onPositionChanged: updateFromX(mouse.x)
        onPressed: updateFromX(mouse.x)
    }
    function clamped(v) { return Math.max(0, Math.min(1, (v - root.min_) / (root.max_ - root.min_ || 1))) }
    function updateFromX(x) {
        var t = Math.max(0, Math.min(1, x / width))
        var v = root.min_ + t * (root.max_ - root.min_)
        root.value = v
        root.changed(v)
    }
}
