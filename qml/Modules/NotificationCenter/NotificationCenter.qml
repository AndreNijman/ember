import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    //  NotificationCenter: 380x580 popup anchored top-right under the bar.
    //  Grouped list of notifications from NotifService.items.
    property bool open_: false
    visible: open_

    implicitWidth: 380
    implicitHeight: 580
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; right: true }
    margins { top: 32; right: 8 }
    exclusiveZone: 0

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width
            height: Theme.rowH
            color: Theme.ink2
            antialiasing: false
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                spacing: Theme.s2
                Text {
                    text: "notifications"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1 }
            }
        }
        ListView {
            id: feed
            width: parent.width
            height: parent.height - Theme.rowH
            clip: true
            model: NotifService.items
            delegate: Notification {
                required property var modelData
                width: feed.width
                appName: modelData.appName || ""
                title: modelData.summary || ""
                body: modelData.body || ""
                urgent: (modelData.urgency || 0) >= 2
                onDismissed: NotifService.dismiss(modelData.id)
            }
        }
    }

}
