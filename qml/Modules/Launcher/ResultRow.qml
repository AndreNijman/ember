import QtQuick
import "../../Theme"

Rectangle {
    id: root
    //  ResultRow: a single launcher result. 32px tall, hairline divider,
    //  accent overlay when selected.
    property string title: ""
    property string subtitle: ""
    property bool selected: false
    signal activated()

    implicitHeight: Theme.rowH
    color: selected ? Theme.ink2 : "transparent"
    antialiasing: false

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s2
        Text {
            text: root.title
            color: root.selected ? Theme.accent : Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.subtitle
            color: Theme.ink5
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
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
}
