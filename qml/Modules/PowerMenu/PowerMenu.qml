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

    anchors { top: true; bottom: true; left: true; right: true }
    color: Qt.rgba(0, 0, 0, 0.85)
    WlrLayershell.namespace: "aqs-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0

    onVisibleChanged: if (visible) _focus.forceActiveFocus()
    Item {
        id: _focus
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }

        MouseArea {
            anchors.fill: parent
            onClicked: root.open_ = false
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.s4

            Cell {
                label: "lock"
                hint: "L"
                onActivated: { root.open_ = false; Ipc.lockEngage() }
            }
            Cell {
                label: "logout"
                hint: ""
                onActivated: { root.open_ = false; runner.exec(["hyprctl", "dispatch", "exit"]) }
            }
            Cell {
                label: "suspend"
                hint: "S"
                onActivated: { root.open_ = false; runner.exec(["systemctl", "suspend"]) }
            }
            Cell {
                label: "reboot"
                hint: "R"
                danger: true
                onActivated: { root.open_ = false; runner.exec(["systemctl", "reboot"]) }
            }
            Cell {
                label: "shutdown"
                hint: "P"
                danger: true
                onActivated: { root.open_ = false; runner.exec(["systemctl", "poweroff"]) }
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.s6
            anchors.horizontalCenter: parent.horizontalCenter
            text: "esc to cancel"
            color: Theme.ink5
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
        }

        Keys.onPressed: (event) => {
            switch (event.key) {
                case Qt.Key_L: root.open_ = false; Ipc.lockEngage(); event.accepted = true; break
                case Qt.Key_S: root.open_ = false; runner.exec(["systemctl", "suspend"]); event.accepted = true; break
                case Qt.Key_R: root.open_ = false; runner.exec(["systemctl", "reboot"]); event.accepted = true; break
                case Qt.Key_P: root.open_ = false; runner.exec(["systemctl", "poweroff"]); event.accepted = true; break
            }
        }
    }

    Process {
        id: runner
        command: ["true"]
        function exec(cmd) { runner.command = cmd; runner.running = true }
    }

    component Cell: Rectangle {
        id: cell
        property string label: ""
        property string hint: ""
        property bool danger: false
        signal activated()

        width: 110
        height: 140
        color: hover.hovered ? Theme.ink2 : Theme.ink1
        border.width: Theme.hairW
        border.color: hover.hovered ? (cell.danger ? Theme.err : Theme.accent) : Theme.hair
        antialiasing: false
        Behavior on color        { ColorAnimation { duration: Theme.tFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.tFast } }

        Column {
            anchors.centerIn: parent
            spacing: Theme.s3
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: cell.hint.length > 0
                text: cell.hint
                color: hover.hovered ? Theme.ink7 : Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
                font.letterSpacing: 0.08 * Theme.t2xs
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: cell.label
                color: hover.hovered ? (cell.danger ? Theme.err : Theme.accent) : Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tmd
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
            }
        }

        Atoms.Hover {
            id: hover
            anchors.fill: parent
            onClicked: cell.activated()
        }
    }
}
