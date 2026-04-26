import QtQuick
import "../../Theme"

Item {
    id: root
    property string path: ""
    property bool active: false
    property bool isCurrentWallpaper: false
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
        border.width: root.active ? 2 : Theme.hairW
        border.color: root.active ? Theme.accent
                     : root.isCurrentWallpaper ? Theme.accent
                     : hover.containsMouse ? Theme.hair
                     : Theme.hairDim
        antialiasing: false
        Behavior on border.color { ColorAnimation { duration: Theme.tFast } }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.picked()
    }
}
