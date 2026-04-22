pragma Singleton
import QtQuick
import Quickshell.Wayland

QtObject {
    id: root
    //  IdleService listens to the compositor idle inhibitor. For now we
    //  expose only a stable surface and a settable inhibitor toggle; the
    //  LockService handles the actual idle -> lock escalation.
    property bool inhibited: false
    signal idleEntered()
    signal idleLeft()

    property IdleInhibitor _inh: IdleInhibitor {
        enabled: root.inhibited
        window: null
    }

    function setInhibited(v) { root.inhibited = v }
}
