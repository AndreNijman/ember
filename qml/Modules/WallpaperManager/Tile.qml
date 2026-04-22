import QtQuick
import "../../Theme"

Item {
    id: root
    property string path: ""
    property bool active: false
    signal picked()

    implicitWidth: 180
    implicitHeight: 110

    Image {
        anchors.fill: parent
        source: "file://" + root.path
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: false
        antialiasing: false
        sourceSize.width: 360
        sourceSize.height: 220
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: root.active ? 2 : (hover.containsMouse ? Theme.hairW : 0)
        border.color: Theme.accent
        antialiasing: false
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.picked()
    }
}
