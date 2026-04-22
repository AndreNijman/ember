import QtQuick
import "../Theme"

Rectangle {
    id: root
    //  Strip is a 2px inset rule used to mark a focused/active tile.
    //  Orientation: Horizontal (bottom/top strip) or Vertical (side strip).
    property int orientation: Qt.Horizontal
    property bool active: false
    implicitWidth:  orientation === Qt.Horizontal ? (parent ? parent.width : 0) : 2
    implicitHeight: orientation === Qt.Horizontal ? 2 : (parent ? parent.height : 0)
    color: active ? Theme.accent : "transparent"
    antialiasing: false
    radius: 0
}
