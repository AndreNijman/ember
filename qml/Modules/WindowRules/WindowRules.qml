import QtQuick
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
    implicitHeight: 520
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-windowrules"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true }
    margins { top: 80 }
    exclusiveZone: 0

    property string filePath: (Quickshell.env("AQS_WINDOWRULES_FILE")
        || ((Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config"))
            + "/hypr/aqs/windowrules.conf"))
    property var rules: []

    onOpen_Changed: if (open_) { rulesFile.reload(); _focus.forceActiveFocus() }

    FileView {
        id: rulesFile
        path: root.filePath
        blockLoading: false
        onLoaded: root.rules = root._parse(this.text())
        onLoadFailed: root.rules = []
    }

    function _parse(text) {
        if (!text) return []
        var out = []
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var raw = lines[i]
            var trimmed = raw.trim()
            if (trimmed.length === 0) continue
            if (trimmed[0] === "#") continue
            out.push({ line: trimmed, index: i })
        }
        return out
    }

    function _serialize() {
        var lines = []
        lines.push("# ember windowrules — written by aqs ipc windowrules")
        for (var i = 0; i < root.rules.length; i++) {
            lines.push(root.rules[i].line)
        }
        return lines.join("\n") + "\n"
    }

    property Process _writer: Process {}

    function save() {
        var body = _serialize()
        _writer.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$AQS_PATH\")\" && printf '%s' \"$AQS_BODY\" > \"$AQS_PATH\" && hyprctl reload >/dev/null 2>&1 || true"]
        _writer.environment = ({ "AQS_PATH": root.filePath, "AQS_BODY": body })
        _writer.running = true
    }

    function addRule(text) {
        if (!text || text.trim().length === 0) return
        var next = root.rules.slice()
        next.push({ line: text.trim(), index: next.length })
        root.rules = next
        save()
    }

    function removeRule(index) {
        var next = []
        for (var i = 0; i < root.rules.length; i++) {
            if (i !== index) next.push(root.rules[i])
        }
        root.rules = next
        save()
    }

    Item {
        id: _focus
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "window rules"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Text {
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "×"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.tmd
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.open_ = false
                }
            }
        }

        ListView {
            id: list
            width: parent.width
            height: root.height - Theme.rowH * 2 - addRow.height
            model: root.rules
            clip: true
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: list.width
                height: Theme.rowH
                color: rowHover.containsMouse ? Theme.ink2 : Theme.ink1
                antialiasing: false
                Behavior on color { ColorAnimation { duration: Theme.tFast } }

                Text {
                    anchors.left: parent.left; anchors.leftMargin: Theme.s3
                    anchors.right: delLink.left; anchors.rightMargin: Theme.s2
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.line
                    color: Theme.ink7
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    elide: Text.ElideRight
                }

                Text {
                    id: delLink
                    anchors.right: parent.right; anchors.rightMargin: Theme.s3
                    anchors.verticalCenter: parent.verticalCenter
                    text: "remove"
                    color: rowHover.containsMouse ? Theme.err : Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.t2xs
                    Behavior on color { ColorAnimation { duration: Theme.tFast } }
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.removeRule(index)
                    }
                }

                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width
                    height: Theme.hairW; color: Theme.hairDim
                    antialiasing: false
                }
            }
        }

        Rectangle {
            visible: root.rules.length === 0
            width: parent.width; height: Theme.rowH * 2
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: "no rules"
                color: Theme.ink5
                font.family: Theme.fontDisplay
                font.italic: true
                font.pixelSize: Theme.tsm
            }
        }

        Rectangle {
            id: addRow
            width: parent.width; height: Theme.tap
            color: Theme.ink2
            antialiasing: false

            Atoms.Field {
                id: addField
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.right: addBtn.left; anchors.rightMargin: Theme.s2
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: "windowrule = float on, match:class ^(pavucontrol)$"
                Keys.onReturnPressed: { root.addRule(addField.text); addField.text = "" }
            }

            Text {
                id: addBtn
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "add"
                color: addBtnHover.containsMouse ? Theme.accent : Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
                MouseArea {
                    id: addBtnHover
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.addRule(addField.text); addField.text = "" }
                }
            }
        }

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink0
            antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "saves to ~/.config/hypr/aqs/windowrules.conf · hyprctl reload"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
            }
        }
    }
}
