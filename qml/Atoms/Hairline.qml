import QtQuick
import "../Theme"

Rectangle {
    id: root
    //  Hairline is a 1px line. Default: horizontal, full width of parent.
    //  Set orientation: Qt.Vertical to get a vertical hairline.
    property int orientation: Qt.Horizontal
    property bool dim: false

    implicitWidth:  orientation === Qt.Horizontal ? (parent ? parent.width : 0) : Theme.hairW
    implicitHeight: orientation === Qt.Horizontal ? Theme.hairW : (parent ? parent.height : 0)
    color: dim ? Theme.hairDim : Theme.hair
    antialiasing: false
}
