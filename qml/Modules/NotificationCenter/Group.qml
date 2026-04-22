import QtQuick
import "../../Theme"
import "../../Services"

Column {
    id: root
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
        Text {
            anchors.right: parent.right
            anchors.rightMargin: Theme.s3
            anchors.verticalCenter: parent.verticalCenter
            text: root.notifications.length + ""
            color: Theme.ink5
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            font.features: {"tnum": 1}
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
            actions: modelData.actions || []
            onDismissed: NotifService.dismiss(modelData.id)
            onActivated: NotifService.invoke(modelData, "default")
            onActionInvoked: (actionId) => NotifService.invoke(modelData, actionId)
        }
    }
}
