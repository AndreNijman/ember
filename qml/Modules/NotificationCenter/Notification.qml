import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string appName: ""
    property string title: ""
    property string body: ""
    property bool urgent: false
    property var actions: []
    signal activated()
    signal dismissed()
    signal actionInvoked(string actionId)

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
        anchors.right: dismissBtn.left
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
        Row {
            visible: root.actions.length > 0
            spacing: Theme.s2
            Repeater {
                model: root.actions
                delegate: Rectangle {
                    required property var modelData
                    width: actionLabel.implicitWidth + Theme.s2 * 2
                    height: Theme.rowH - Theme.s2
                    color: Theme.ink2
                    border.width: Theme.hairW
                    border.color: Theme.hair
                    antialiasing: false
                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text || ""
                        color: Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.actionInvoked(modelData.id || "")
                    }
                }
            }
        }
    }

    Text {
        id: dismissBtn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.s3
        anchors.topMargin: Theme.s2
        text: "×"
        color: Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tmd
        MouseArea {
            anchors.fill: parent
            anchors.margins: -Theme.s1
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.hairW
        color: Theme.hairDim
        antialiasing: false
    }
    MouseArea {
        anchors.left: parent.left
        anchors.right: dismissBtn.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        onClicked: root.activated()
    }
}
