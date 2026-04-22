import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string label: ""
    property bool on: false
    property bool expandable: false
    property bool expanded: false
    signal toggled(bool value)
    signal expandClicked()

    implicitHeight: Theme.tap
    implicitWidth: 160
    color: on ? Theme.ink2 : Theme.ink1
    border.width: Theme.hairW
    border.color: on ? Theme.accent : Theme.hair
    antialiasing: false

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s3
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.on ? Theme.accent : Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
        }
    }

    Text {
        visible: root.expandable
        anchors.right: parent.right
        anchors.rightMargin: Theme.s3
        anchors.verticalCenter: parent.verticalCenter
        text: root.expanded ? "‹" : "›"
        color: Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tmd
        MouseArea {
            anchors.fill: parent
            anchors.margins: -Theme.s2
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expandClicked()
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expandable ? parent.width - 32 : parent.width
        onClicked: { root.on = !root.on; root.toggled(root.on) }
    }
}
