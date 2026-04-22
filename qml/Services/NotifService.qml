pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root
    //  NotifService exposes the live notification list + provides mute /
    //  clear helpers. The live server is Quickshell's NotificationServer
    //  singleton; we wrap it to keep modules off the raw API.
    property var items: NotificationServer.trackedNotifications
        ? NotificationServer.trackedNotifications.values
        : []
    property bool dnd: false

    function setDnd(v) { root.dnd = v }
    function dismiss(id) {
        for (var i = 0; i < items.length; i++) {
            if (items[i].id === id) { items[i].dismiss(); return }
        }
    }
    function clearAll() {
        var snapshot = items.slice()
        for (var i = 0; i < snapshot.length; i++) snapshot[i].dismiss()
    }

    Component.onCompleted: {
        NotificationServer.keepOnReload = false
        NotificationServer.imageSupported = true
        NotificationServer.actionsSupported = true
        NotificationServer.bodyMarkupSupported = true
    }
}
