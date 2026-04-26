import QtQuick
import "../Theme"

//  Hover: invisible hit-tester that exposes a `hovered` flag with no
//  on/off snap. Pair with a Behavior on the receiving color/opacity
//  property so every interactive surface fades the same way.
//
//  Usage:
//      Atoms.Hover { id: hover; anchors.fill: parent; onClicked: ... }
//      ...
//      Text { color: hover.hovered ? Theme.ink8 : Theme.ink6
//             Behavior on color { ColorAnimation { duration: Theme.tFast } } }
//
//  Children: forwards `clicked`, `pressed`, `released` so callers don't
//  have to nest a second MouseArea.
MouseArea {
    id: root
    property alias hovered: root.containsMouse
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
}
