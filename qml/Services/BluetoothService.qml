pragma Singleton
import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property bool discovering: adapter ? adapter.discovering : false
    readonly property int connectedCount: {
        var n = 0
        for (var i = 0; i < devices.length; i++) if (devices[i].connected) n++
        return n
    }

    function setPowered(v) {
        if (adapter) adapter.enabled = v
    }
    function startScan() {
        if (adapter && !adapter.discovering) adapter.discovering = true
    }
    function stopScan() {
        if (adapter && adapter.discovering) adapter.discovering = false
    }
    function connectDevice(dev) {
        if (dev) dev.connected = true
    }
    function disconnectDevice(dev) {
        if (dev) dev.connected = false
    }
    function pairDevice(dev) {
        if (dev && dev.pair) dev.pair()
    }
    function forgetDevice(dev) {
        if (dev && dev.forget) dev.forget()
    }
    function togglePower() {
        setPowered(!powered)
    }
    function trustDevice(dev) {
        if (dev) dev.trusted = true
    }
}
