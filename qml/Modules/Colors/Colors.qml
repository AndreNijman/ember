import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 320
    implicitHeight: column.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-colors"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: 0; right: 0 }
    exclusiveZone: 0

    onVisibleChanged: if (visible) _focus.forceActiveFocus()
    Item {
        id: _focus; focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    Column {
        id: column
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "colors"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Row {
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.s3
                Text {
                    text: "wipe"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ColorService.clear()
                    }
                }
                Text {
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
        }

        Rectangle {
            width: parent.width; height: Theme.tap; color: Theme.ink1
            antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "+ pick color"
                color: pickHover.containsMouse ? Theme.accent : Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
            }
            MouseArea {
                id: pickHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { ColorService.pick(); root.open_ = false }
            }
        }

        Atoms.Hairline { width: parent.width }

        Grid {
            id: grid
            visible: ColorService.history.length > 0
            width: parent.width
            columns: 4
            rowSpacing: 1
            columnSpacing: 1
            Repeater {
                model: ColorService.history
                delegate: Rectangle {
                    required property string modelData
                    width: (grid.width - 3) / 4
                    height: 64
                    color: modelData
                    antialiasing: false

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.s1
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData
                        color: Theme.ink0
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                        font.features: {"tnum": 1}
                        opacity: hover.containsMouse ? 1 : 0.6
                        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { copyProc.command = ["sh", "-c", "printf '%s' \"" + modelData + "\" | wl-copy"]; copyProc.running = true }
                    }
                }
            }
        }

        Rectangle {
            visible: ColorService.history.length === 0
            width: parent.width; height: Theme.tap
            color: Theme.ink0
            antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "no colors picked yet"
                color: Theme.ink5
                font.family: Theme.fontDisplay
                font.italic: true
                font.pixelSize: Theme.tsm
            }
        }
    }

    property Process copyProc: Process {}
}
