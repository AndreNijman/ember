import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

// Multi-monitor: bar renders on every output (via Variants in shell.qml).
// Status cluster (right) shows on all outputs. MPRIS media and notifications
// are singleton PanelWindows, so they appear once on the primary output.
PanelWindow {
    id: root
    visible: !LockService.locked
    anchors {
        top:    true
        left:   true
        right:  true
    }
    implicitHeight: Theme.barH
    color: Theme.ink1
    exclusiveZone: Theme.barH
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "aqs-bar"

    Rectangle {
        anchors.fill: parent
        color: Theme.ink1
        antialiasing: false
    }

    Row {
        id: leftCluster
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.s2
        IdentityGlyph {}
        WorkspaceStrip {}
    }

    Clock {
        anchors.centerIn: parent
    }

    Row {
        id: centerLeftCluster
        anchors.left: leftCluster.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.s3
        spacing: Theme.s2
        clip: true

        FocusedWindow { id: focusTitle }

        Atoms.Hairline {
            orientation: Qt.Vertical
            height: Theme.barH - Theme.s2 * 2
            anchors.verticalCenter: parent.verticalCenter
            dim: true
            visible: focusTitle.visible && tray.visible
        }

        TrayStrip { id: tray }

        Atoms.Hairline {
            orientation: Qt.Vertical
            height: Theme.barH - Theme.s2 * 2
            anchors.verticalCenter: parent.verticalCenter
            dim: true
            visible: nowPlaying.visible && (focusTitle.visible || tray.visible)
        }

        NowPlaying { id: nowPlaying }
    }

    Row {
        id: rightCluster
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.s2
        Vpn {}
        Network {}
        Volume {}
        Battery {}
        Rectangle {
            visible: NotifService.items.length > 0 && !NotifService.dnd
            width: 4; height: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.accent
            antialiasing: false
        }
    }

    Atoms.Hairline {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
