import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"

PopupWindow {
    id: root
    //  Toast: per-notification transient popup 320xauto anchored top-right.
    //  The Toast is dismissed on timer and does not accept swipe actions.
    property var notification: null
    visible: notification !== null

    implicitWidth: 320
    implicitHeight: content.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-toast"
    anchor.window: null

    Column {
        id: content
        width: parent.width
        Notification {
            width: parent.width
            title: root.notification ? (root.notification.summary || "") : ""
            body:  root.notification ? (root.notification.body || "") : ""
            appName: root.notification ? (root.notification.appName || "") : ""
        }
    }
    Timer {
        interval: 5000
        running: root.visible
        onTriggered: root.notification = null
    }
}
