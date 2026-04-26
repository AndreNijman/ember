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
        color: hover.containsMouse ? Theme.ink3 : Theme.ink2
        antialiasing: false
        Behavior on color { ColorAnimation { duration: Theme.tFast } }

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
        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.s3
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.s3
            Text {
                visible: hover.containsMouse
                text: "clear"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var snap = root.notifications.slice()
                        for (var i = 0; i < snap.length; i++) NotifService.dismiss(snap[i].id)
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.notifications.length + ""
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                font.features: {"tnum": 1}
            }
        }
        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
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
