import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    //  TopBar: 28px PanelWindow anchored to top of every output. Canvas
    //  is ink1; a single hairline at the bottom edge separates it from
    //  the desktop. Three horizontal regions: left (identity + workspaces),
    //  centre (focused title), right (network/volume/battery/clock).

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

    FocusedWindow {
        anchors.left: leftCluster.right
        anchors.right: rightCluster.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
    }

    Atoms.Hairline {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
