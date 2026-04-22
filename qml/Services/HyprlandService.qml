pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    id: root
    //  HyprlandService exposes a small strongly-typed view of Hyprland state
    //  to the shell: workspaces, focused workspace, focused window title.
    //  Backend: Quickshell.Hyprland — Hyprland.workspaces + focusedWorkspace.

    property var workspaces: Hyprland.workspaces ? Hyprland.workspaces.values : []
    property int focusedWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    property string focusedWindowTitle: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title || "") : ""

    signal workspaceChanged(int id)

    function dispatch(cmd) {
        Hyprland.dispatch(cmd)
    }
    function focusWorkspace(id) {
        Hyprland.dispatch("workspace " + id)
    }
}
