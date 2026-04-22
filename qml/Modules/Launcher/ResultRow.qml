import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property bool selected: false
    signal activated()

    implicitHeight: Theme.rowH
    color: selected ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
    antialiasing: false

    Atoms.Strip {
        orientation: Qt.Vertical
        active: root.selected
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s2

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width: 24; height: 24
            source: root.iconName ? "image://icon/" + root.iconName : ""
            sourceSize: Qt.size(24, 24)
            visible: status === Image.Ready
        }
        Item {
            visible: root.iconName.length === 0 || !parent.children[0].visible
            width: 24; height: 24
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.title
            color: root.selected ? Theme.accent : Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.selected ? root.subtitle : _shortSub(root.subtitle)
            color: Theme.ink5
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            width: Math.max(0, parent.width - parent.children[0].width - parent.children[2].implicitWidth - Theme.s2 * 3 - 24)
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.hairW
        color: Theme.hairDim
        antialiasing: false
    }
    MouseArea { anchors.fill: parent; onClicked: root.activated() }

    function _shortSub(s) {
        if (!s || s.length === 0) return ""
        var parts = s.split("/")
        return parts[parts.length - 1]
    }
}
