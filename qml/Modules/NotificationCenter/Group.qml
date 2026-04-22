import QtQuick
import "../../Theme"

Column {
    id: root
    //  Group: a heading (app name) with a stack of notifications under it.
    property string appName: ""
    property var notifications: []

    width: parent ? parent.width : 0
    spacing: 0

    Rectangle {
        width: parent.width
        height: Theme.rowH
        color: Theme.ink2
        antialiasing: false
        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.s3
            anchors.verticalCenter: parent.verticalCenter
            text: root.appName
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            font.capitalization: Font.AllUppercase
        }
    }
    Repeater {
        model: root.notifications
        delegate: Notification {
            required property var modelData
            width: root.width
            appName: root.appName
            title: modelData.summary || ""
            body: modelData.body || ""
            urgent: (modelData.urgency || 0) >= 2
        }
    }
}
