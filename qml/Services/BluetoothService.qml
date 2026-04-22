pragma Singleton
import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root
    //  BluetoothService wraps Quickshell.Bluetooth. Props that the shell
    //  reads are exposed here; actions delegate straight to the adapter.
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property int connectedCount: {
        var n = 0
        for (var i = 0; i < devices.length; i++) if (devices[i].connected) n++
        return n
    }

    function setPowered(v) {
        if (adapter) adapter.enabled = v
    }
}
