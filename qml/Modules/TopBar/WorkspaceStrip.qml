import QtQuick
import "../../Theme"
import "../../Services"

Row {
    id: root
    spacing: 0

    property var visibleWorkspaces: {
        var byId = {}
        var ws = HyprlandService.workspaces
        for (var i = 0; i < ws.length; i++) {
            if (ws[i] && ws[i].id > 0) byId[ws[i].id] = ws[i]
        }
        var focused = HyprlandService.focusedWorkspaceId
        if (focused > 0 && !byId[focused]) byId[focused] = { id: focused, name: "" }
        var ids = Object.keys(byId).map(Number).sort(function(a, b) { return a - b })
        return ids.map(function(id) { return byId[id] })
    }

    Repeater {
        model: root.visibleWorkspaces
        delegate: WorkspacePip {
            required property var modelData
            wsId: modelData.id
            wsName: modelData.name && String(modelData.name) !== String(modelData.id) ? String(modelData.name) : ""
            focused: HyprlandService.focusedWorkspaceId === modelData.id
            onClicked: HyprlandService.focusWorkspace(modelData.id)
        }
    }
}
