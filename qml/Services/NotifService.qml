pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool dnd: false
    property var items: _server.trackedNotifications.values
    property int count: items.length

    signal toastPosted(var notification)

    property NotificationServer _server: NotificationServer {
        // Survives `aqs ipc shell restart` (in-process reload). Across full
        // process restart notifications are still lost — DBus daemon
        // tracking is the only place they live; we don't keep an external
        // JSON because re-rendered placeholder objects can't `invoke()`
        // actions back to the originating client anyway.
        keepOnReload: true
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        persistenceSupported: true

        onNotification: (n) => {
            n.tracked = true
            if (!root.dnd) root.toastPosted(n)
        }
    }

    function setDnd(v) { root.dnd = v }
    function dismiss(id) {
        var snap = items
        for (var i = 0; i < snap.length; i++) {
            if (snap[i].id === id) { snap[i].dismiss(); return }
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
}
