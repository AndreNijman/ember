import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms

PanelWindow {
    id: root
    //  TopBar: 28px PanelWindow anchored to top of every output. Canvas
    //  is ink1; a single hairline at the bottom edge separates it from
    //  the desktop. Three horizontal regions: left (identity + workspaces),
    //  centre (focused title), right (network/volume/battery/clock).

    anchors {
        top:    true
        left:   true
        right:  true
    }
    implicitHeight: Theme.barH
    color: Theme.ink1
    exclusionMode: ExclusionMode.Normal
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

    FocusedWindow {
        anchors.centerIn: parent
        width: Math.min(root.width * 0.5, 480)
    }

    Row {
        id: rightCluster
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.s2
        Network {}
        Volume {}
        Battery {}
        Clock {}
    }

    Atoms.Hairline {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
