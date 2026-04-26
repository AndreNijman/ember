pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

QtObject {
    id: root

    property bool inhibited: false
    property int dpmsTimeoutSec: 180
    property int lockTimeoutSec: 300

    property bool dpmsOff: false

    signal idleEntered()
    signal idleLeft()

    property IdleInhibitor _inh: IdleInhibitor {
        enabled: root.inhibited
        window: null
    }

    property IdleMonitor _dpmsMon: IdleMonitor {
        enabled: !root.inhibited && root.dpmsTimeoutSec > 0
        timeout: root.dpmsTimeoutSec
        onIsIdleChanged: {
            if (isIdle) {
                root._dpms(false)
                root.idleEntered()
            } else {
                if (root.dpmsOff) root._dpms(true)
                root.idleLeft()
            }
        }
    }

    property IdleMonitor _lockMon: IdleMonitor {
        enabled: !root.inhibited && root.lockTimeoutSec > 0
        timeout: root.lockTimeoutSec
        onIsIdleChanged: {
            if (isIdle && !LockService.locked) LockService.lock()
        }
    }

    property Process _dpmsProc: Process {
        command: ["true"]
    }

    function _dpms(on) {
        _dpmsProc.command = ["hyprctl", "dispatch", "dpms", on ? "on" : "off"]
        _dpmsProc.running = true
        root.dpmsOff = !on
    }

    function setInhibited(v) { root.inhibited = v }
    function setDpmsTimeout(sec) { root.dpmsTimeoutSec = sec }
    function setLockTimeout(sec) { root.lockTimeoutSec = sec }
}
