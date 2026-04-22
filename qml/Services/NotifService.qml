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
    property int count: items.length

    signal toastPosted(var notification)

    property var _seen: ({})

    onCountChanged: {
        for (var i = 0; i < items.length; i++) {
            var n = items[i]
            if (n && n.id !== undefined && !_seen[n.id]) {
                _seen[n.id] = true
                if (!root.dnd) toastPosted(n)
            }
        }
    }

    function setDnd(v) { root.dnd = v }
    function dismiss(id) {
        for (var i = 0; i < items.length; i++) {
            if (items[i].id === id) { items[i].dismiss(); return }
        }
    }
    function invoke(notif, actionId) {
        if (notif && notif.invoke) notif.invoke(actionId)
    }
    function clearAll() {
        var snapshot = items.slice()
        for (var i = 0; i < snapshot.length; i++) snapshot[i].dismiss()
    }

    function grouped() {
        var groups = {}
        var order = []
        for (var i = 0; i < items.length; i++) {
            var app = items[i].appName || "other"
            if (!groups[app]) { groups[app] = []; order.push(app) }
            groups[app].push(items[i])
        }
        var result = []
        for (var j = 0; j < order.length; j++) {
            var g = groups[order[j]]
            if (g.length >= 3) {
                result.push({ type: "group", appName: order[j], items: g })
            } else {
                for (var k = 0; k < g.length; k++)
                    result.push({ type: "single", notification: g[k] })
            }
        }
        return result
    }

    Component.onCompleted: {
        NotificationServer.keepOnReload = false
        NotificationServer.imageSupported = true
        NotificationServer.actionsSupported = true
        NotificationServer.bodyMarkupSupported = true
    }
}
