import QtQuick
import "../Theme"

Item {
    id: root
    //  Row is a generic list row: fixed height, one hairline at the bottom,
    //  left + right slots filled via default property. Used by panels.
    default property alias content: inner.data
    property bool last: false
    property int pad: Theme.s3

    implicitHeight: Theme.rowH
    implicitWidth: parent ? parent.width : 0

    Item {
        id: inner
        anchors.fill: parent
        anchors.leftMargin: root.pad
        anchors.rightMargin: root.pad
    }
    Rectangle {
        visible: !root.last
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.hairW
        color: Theme.hairDim
        antialiasing: false
    }
}
