import QtQuick
import "../../Theme"

Rectangle {
    id: root
    //  Notification row: title in mono, body on a second line in ink6,
    //  age on the right. No radius, one accent strip on the left if urgent.
    property string appName: ""
    property string title: ""
    property string body: ""
    property string age: ""
    property bool urgent: false
    signal activated()
    signal dismissed()

    implicitHeight: content.implicitHeight + Theme.s2 * 2
    color: Theme.ink1
    border.width: 0

    Rectangle {
        visible: root.urgent
        width: 2
        height: parent.height
        color: Theme.err
        antialiasing: false
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.s3
        anchors.top: parent.top
        anchors.topMargin: Theme.s2
        spacing: 2
        Row {
            spacing: Theme.s2
            Text {
                text: root.appName
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
            Text {
                text: root.age
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
        Text {
            text: root.title
            color: Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            width: content.width
            wrapMode: Text.WordWrap
        }
        Text {
            text: root.body
            visible: root.body.length > 0
            color: Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            width: content.width
            wrapMode: Text.WordWrap
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
