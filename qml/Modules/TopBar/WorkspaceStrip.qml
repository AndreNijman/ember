import QtQuick
import "../../Theme"
import "../../Services"

Row {
    id: root
    //  WorkspaceStrip renders 10 pips wired to HyprlandService. The number
    //  of pips is fixed (1..10) to match Hyprland defaults; occupied/focus
    //  state comes from HyprlandService.workspaces.
    spacing: 0

    Repeater {
        model: 10
        delegate: WorkspacePip {
            required property int index
            wsId: index + 1
            focused: HyprlandService.focusedWorkspaceId === (index + 1)
            occupied: {
                for (var i = 0; i < HyprlandService.workspaces.length; i++) {
                    if (HyprlandService.workspaces[i].id === (index + 1)) return true
                }
                return false
            }
            onClicked: HyprlandService.focusWorkspace(index + 1)
        }
    }
}
