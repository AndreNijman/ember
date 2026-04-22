import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    visible: toastModel.count > 0
    implicitWidth: 320
    implicitHeight: col.implicitHeight
    color: "transparent"
    WlrLayershell.namespace: "aqs-toast"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; right: true }
    margins { top: 36; right: 8 }
    exclusiveZone: 0

    property int maxToasts: 3

    ListModel { id: toastModel }

    Connections {
        target: NotifService
        function onToastPosted(notification) {
            if (toastModel.count >= root.maxToasts)
                toastModel.remove(0)
            toastModel.append({
                nId: notification.id,
                nApp: notification.appName || "",
                nTitle: notification.summary || "",
                nBody: notification.body || "",
                nUrgent: (notification.urgency || 0) >= 2
            })
        }
    }

    Column {
        id: col
        width: parent.width
        spacing: Theme.s1

        Repeater {
            model: toastModel
            delegate: Rectangle {
                required property int index
                required property int nId
                required property string nApp
                required property string nTitle
                required property string nBody
                required property bool nUrgent

                width: col.width
                height: inner.implicitHeight + Theme.s3 * 2
                color: Theme.ink1
                border.width: Theme.hairW
                border.color: nUrgent ? Theme.err : Theme.hair
                antialiasing: false

                Column {
                    id: inner
                    anchors.fill: parent
                    anchors.margins: Theme.s3
                    spacing: 2
                    Text {
                        text: nApp
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                    Text {
                        text: nTitle
                        color: Theme.ink8
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                        width: inner.width
                        elide: Text.ElideRight
                    }
                    Text {
                        visible: nBody.length > 0
                        text: nBody
                        color: Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        width: inner.width
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: Theme.s2
                    anchors.topMargin: Theme.s2
                    text: "×"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toastModel.remove(index)
                    }
                }

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 24
                    onClicked: {
                        NotifService.invoke(null, "default")
                        toastModel.remove(index)
                    }
                }

                Timer {
                    interval: nUrgent ? 0 : 6000
                    running: !nUrgent
                    onTriggered: {
                        if (index >= 0 && index < toastModel.count)
                            toastModel.remove(index)
                    }
                }
            }
        }
    }
}
