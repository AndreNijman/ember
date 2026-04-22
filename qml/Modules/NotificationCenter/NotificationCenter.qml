import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 380
    implicitHeight: 580
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: 0; right: 0 }
    exclusiveZone: 0

    onVisibleChanged: if (visible) _focus.forceActiveFocus()
    Item {
        id: _focus; focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width
            height: Theme.rowH
            color: Theme.ink2
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.s3
                text: "notifications"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.s3
                spacing: Theme.s3
                Text {
                    visible: NotifService.items.length > 0
                    text: "clear all"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotifService.clearAll()
                    }
                }
                Text {
                    text: "×"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.open_ = false
                    }
                }
            }
        }

        ListView {
            id: feed
            width: parent.width
            height: parent.height - Theme.rowH
            clip: true
            model: NotifService.grouped()

            delegate: Loader {
                required property var modelData
                required property int index
                width: feed.width
                sourceComponent: modelData.type === "group" ? groupComp : singleComp

                Component {
                    id: groupComp
                    Group {
                        width: feed.width
                        appName: modelData.appName || ""
                        notifications: modelData.items || []
                    }
                }
                Component {
                    id: singleComp
                    Notification {
                        width: feed.width
                        appName: modelData.notification ? (modelData.notification.appName || "") : ""
                        title: modelData.notification ? (modelData.notification.summary || "") : ""
                        body: modelData.notification ? (modelData.notification.body || "") : ""
                        urgent: modelData.notification ? ((modelData.notification.urgency || 0) >= 2) : false
                        actions: modelData.notification && modelData.notification.actions ? modelData.notification.actions : []
                        onDismissed: {
                            if (modelData.notification)
                                NotifService.dismiss(modelData.notification.id)
                        }
                        onActivated: {
                            if (modelData.notification)
                                NotifService.invoke(modelData.notification, "default")
                        }
                        onActionInvoked: (actionId) => {
                            if (modelData.notification)
                                NotifService.invoke(modelData.notification, actionId)
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: NotifService.items.length === 0
            width: parent.width
            height: parent.height - Theme.rowH
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: "no notifications"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
        }
    }
}
