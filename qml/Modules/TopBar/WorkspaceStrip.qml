import QtQuick
import "../../Theme"
import "../../Services"

Row {
    id: root
    spacing: 0

    property var visibleIds: {
        var ids = {}
        var ws = HyprlandService.workspaces
        for (var i = 0; i < ws.length; i++) {
            if (ws[i] && ws[i].id > 0) ids[ws[i].id] = true
        }
        var focused = HyprlandService.focusedWorkspaceId
        if (focused > 0) ids[focused] = true
        return Object.keys(ids).map(Number).sort(function(a, b) { return a - b })
    }

    Repeater {
        model: root.visibleIds
        delegate: WorkspacePip {
            required property var modelData
            wsId: modelData
            focused: HyprlandService.focusedWorkspaceId === modelData
            onClicked: HyprlandService.focusWorkspace(modelData)
        }
    }
}
