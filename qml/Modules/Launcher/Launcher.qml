import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 640
    implicitHeight: column.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true }
    margins { top: 200 }
    exclusiveZone: 0

    property string mode: {
        var t = input.text
        if (t.startsWith("=")) return "calc"
        if (t.startsWith(">")) return "shell"
        if (t.startsWith(":")) return "window"
        if (t.startsWith("?")) return "clipboard"
        return "app"
    }

    onOpen_Changed: {
        if (!open_) { input.text = ""; shellOutput.text = "" }
    }

    Column {
        id: column
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.hairW
            color: Theme.hair; antialiasing: false
        }
        Item {
            width: parent.width
            height: input.implicitHeight
            Atoms.Field {
                id: input
                width: parent.width
                placeholderText: "run, search, or =expr >cmd :window ?clip"
                focus: root.open_
                onTextChanged: {
                    if (root.mode === "app") AppService.query = text
                    else if (root.mode === "window") windowSearch.refresh(text.substring(1))
                    else if (root.mode === "clipboard") clipSearch.refresh(text.substring(1))
                }
                Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
                Keys.onReturnPressed: (event) => {
                    if (root.mode === "app" && AppService.results.length > 0) {
                        AppService.launch(AppService.results[list.currentIndex].id)
                        root.open_ = false
                    } else if (root.mode === "shell") {
                        shellRunner.run(input.text.substring(1).trim())
                    } else if (root.mode === "window" && windowSearch.results.length > 0) {
                        windowSearch.focus(list.currentIndex)
                        root.open_ = false
                    } else if (root.mode === "clipboard" && clipSearch.results.length > 0) {
                        clipSearch.paste(list.currentIndex)
                        root.open_ = false
                    }
                    event.accepted = true
                }
                Keys.onUpPressed: { list.decrementCurrentIndex(); event.accepted = true }
                Keys.onDownPressed: { list.incrementCurrentIndex(); event.accepted = true }
            }
            Text {
                visible: root.mode !== "app"
                anchors.right: parent.right
                anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: root.mode === "calc" ? "calc" : root.mode === "shell" ? "shell" : root.mode === "window" ? "window" : root.mode === "clipboard" ? "clip" : ""
                color: Theme.accent
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
        CalcStrip {
            width: parent.width
            query: input.text
        }
        Rectangle {
            visible: root.mode === "shell" && shellOutput.text.length > 0
            width: parent.width
            height: visible ? Math.min(200, shellOutput.implicitHeight + Theme.s3 * 2) : 0
            color: Theme.ink0
            Text {
                id: shellOutput
                anchors.fill: parent
                anchors.margins: Theme.s3
                color: Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                wrapMode: Text.Wrap
            }
        }
        ListView {
            id: list
            width: parent.width
            height: Math.min(320, contentHeight)
            clip: true
            model: {
                if (root.mode === "app") return AppService.results
                if (root.mode === "window") return windowSearch.results
                if (root.mode === "clipboard") return clipSearch.results
                return []
            }
            delegate: ResultRow {
                required property var modelData
                required property int index
                width: list.width
                title: modelData.name || modelData.title || ""
                subtitle: modelData.exec || modelData.subtitle || ""
                iconName: modelData.icon || ""
                selected: list.currentIndex === index
                onActivated: {
                    if (root.mode === "app") {
                        AppService.launch(modelData.id)
                        root.open_ = false
                    } else if (root.mode === "window") {
                        windowSearch.focus(index)
                        root.open_ = false
                    } else if (root.mode === "clipboard") {
                        clipSearch.paste(index)
                        root.open_ = false
                    }
                }
            }
            keyNavigationWraps: true
        }
        Rectangle {
            width: parent.width; height: Theme.rowH
            color: Theme.ink0; antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                text: "⏎ run   ↑↓ nav   ⎋ close"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
        Rectangle {
            width: parent.width; height: Theme.hairW
            color: Theme.hair; antialiasing: false
        }
    }

    QtObject {
        id: shellRunner
        property var _proc: null
        function run(cmd) {
            shellOutput.text = "running..."
            _runProc.command = ["sh", "-c", cmd]
            _runProc.running = true
        }
    }
    Process {
        id: _runProc
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: shellOutput.text = (this.text || "").trim()
        }
    }

    QtObject {
        id: windowSearch
        property var results: []
        function refresh(q) {
            _winProc.command = ["hyprctl", "clients", "-j"]
            _winProc.running = true
            windowSearch._query = q
        }
        property string _query: ""
        function focus(idx) {
            if (idx >= 0 && idx < results.length) {
                var addr = results[idx].address || ""
                HyprlandService.dispatch("focuswindow address:" + addr)
            }
        }
    }
    Process {
        id: _winProc
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var all = JSON.parse(this.text || "[]")
                    var q = windowSearch._query.toLowerCase()
                    var out = []
                    for (var i = 0; i < all.length; i++) {
                        var w = all[i]
                        var t = (w.title || "").toLowerCase()
                        var c = (w.class || "").toLowerCase()
                        if (!q || t.indexOf(q) >= 0 || c.indexOf(q) >= 0) {
                            out.push({
                                name: w.title || w.class || "",
                                subtitle: "workspace " + (w.workspace ? w.workspace.id : "?"),
                                address: w.address || ""
                            })
                        }
                    }
                    windowSearch.results = out
                } catch(e) { windowSearch.results = [] }
            }
        }
    }

    QtObject {
        id: clipSearch
        property var results: []
        function refresh(q) {
            _clipProc.command = ["sh", "-c", "cliphist list 2>/dev/null | head -50"]
            _clipProc.running = true
            clipSearch._query = q
        }
        property string _query: ""
        function paste(idx) {
            if (idx >= 0 && idx < results.length) {
                var id = results[idx].clipId || ""
                _pasteProc.command = ["sh", "-c", "cliphist decode " + id + " | wl-copy"]
                _pasteProc.running = true
            }
        }
    }
    Process {
        id: _clipProc
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (this.text || "").split("\n")
                var q = clipSearch._query.toLowerCase()
                var out = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t")
                    if (parts.length < 2) continue
                    var content = parts.slice(1).join("\t")
                    if (q && content.toLowerCase().indexOf(q) < 0) continue
                    out.push({
                        name: content.substring(0, 80),
                        subtitle: "",
                        clipId: parts[0].trim()
                    })
                }
                clipSearch.results = out
            }
        }
    }
    Process {
        id: _pasteProc
        command: ["true"]
    }
}
