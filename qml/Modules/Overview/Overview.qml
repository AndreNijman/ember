import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    anchors { top: true; bottom: true; left: true; right: true }
    color: "#000000"
    WlrLayershell.namespace: "aqs-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    property var snapshots: ({})
    property var workspaceIds: {
        var ids = []
        var ws = HyprlandService.workspaces
        for (var i = 0; i < ws.length; i++) {
            if (ws[i] && ws[i].id > 0) ids.push(ws[i].id)
        }
        ids.sort(function(a, b) { return a - b })
        return ids
    }

    onOpen_Changed: if (open_) _captureAll()

    function _captureAll() {
        for (var i = 0; i < workspaceIds.length; i++) {
            _capture(workspaceIds[i])
        }
    }

    function _capture(wsId) {
        var path = "/tmp/aqs-overview-" + wsId + ".png"
        _capProc.command = ["sh", "-c", "grim -o '' -t png " + path + " 2>/dev/null; echo " + wsId + ":" + path]
        _capProc.running = true
    }

    Process {
        id: _capProc
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = (this.text || "").trim().split(":")
                if (parts.length >= 2) {
                    var id = parseInt(parts[0])
                    var path = parts.slice(1).join(":")
                    var copy = {}
                    for (var k in root.snapshots) copy[k] = root.snapshots[k]
                    copy[id] = "file://" + path + "?" + Date.now()
                    root.snapshots = copy
                }
            }
        }
    }

    Item {
        id: focusGrab
        focus: true
        Component.onCompleted: if (root.visible) forceActiveFocus()
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.s3

        Text {
            text: "workspaces"
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
        }

        Grid {
            columns: 3
            rowSpacing: Theme.s3
            columnSpacing: Theme.s3

            Repeater {
                model: root.workspaceIds
                delegate: Rectangle {
                    required property var modelData
                    property int wsId: modelData
                    property bool isFocused: HyprlandService.focusedWorkspaceId === wsId

                    width: 280; height: 180
                    color: Theme.ink2
                    border.width: isFocused ? 2 : Theme.hairW
                    border.color: isFocused ? Theme.accent : Theme.hair
                    antialiasing: false

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: root.snapshots[wsId] || ""
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: Theme.s2
                        text: wsId
                        color: isFocused ? Theme.accent : Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tmd
                        font.features: {"tnum": 1}
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            HyprlandService.focusWorkspace(wsId)
                            root.open_ = false
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: if (visible) focusGrab.forceActiveFocus()
}
