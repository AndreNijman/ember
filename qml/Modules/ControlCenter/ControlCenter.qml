import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 380
    implicitHeight: Math.min(720, column.implicitHeight)
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-control"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: Theme.barH; right: 0 }
    exclusiveZone: 0

    property string expandedPanel: ""

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
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.s3
                text: "control"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.s3
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
        Grid {
            columns: 2
            rowSpacing: 0
            columnSpacing: 0
            width: parent.width
            ToggleTile {
                label: "wifi"; on: NetworkService.online; width: parent.width / 2
                expandable: true
                expanded: root.expandedPanel === "wifi"
                onExpandClicked: root.expandedPanel = root.expandedPanel === "wifi" ? "" : "wifi"
            }
            ToggleTile {
                label: "bluetooth"; on: BluetoothService.powered; width: parent.width / 2
                expandable: true
                expanded: root.expandedPanel === "bt"
                onToggled: (v) => BluetoothService.setPowered(v)
                onExpandClicked: root.expandedPanel = root.expandedPanel === "bt" ? "" : "bt"
            }
            ToggleTile {
                label: "dnd"; on: NotifService.dnd; width: parent.width / 2
                onToggled: (v) => NotifService.setDnd(v)
            }
            ToggleTile {
                label: "idle hold"; on: IdleService.inhibited; width: parent.width / 2
                onToggled: (v) => IdleService.setInhibited(v)
            }
        }
        WifiPanel {
            width: parent.width
            visible: root.expandedPanel === "wifi"
        }
        BluetoothPanel {
            width: parent.width
            visible: root.expandedPanel === "bt"
        }
        Atoms.Hairline { width: parent.width }
        AudioOutputPanel { width: parent.width }
        Atoms.Hairline { width: parent.width }
        AudioInputPanel { width: parent.width }
        Atoms.Hairline { width: parent.width }
        Item {
            width: parent.width
            height: Theme.rowH * 2
            Column {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: Theme.s1
                Text {
                    text: "brightness"
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
                Atoms.Slider {
                    width: parent.width
                    value: BrightnessService.value
                    onChanged: BrightnessService.set(value)
                }
            }
        }
        Atoms.Hairline { width: parent.width }
        Item {
            width: parent.width
            height: Theme.rowH
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                spacing: Theme.s3
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "battery · " + Math.round(PowerService.percent * 100) + "%"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                    font.features: {"tnum": 1}
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (PowerService.charging) return "charging"
                        if (PowerService.onBattery) {
                            var sec = PowerService.timeSec
                            if (sec > 0) {
                                var h = Math.floor(sec / 3600)
                                var m = Math.floor((sec % 3600) / 60)
                                return h + "h " + m + "m remaining"
                            }
                            return "on battery"
                        }
                        return "AC"
                    }
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    font.features: {"tnum": 1}
                }
            }
        }
        PowerProfileRow { width: parent.width }
        Atoms.Hairline { width: parent.width }
        MediaTile { width: parent.width }
        Atoms.Hairline { width: parent.width; visible: MprisService.hasPlayer }
        PowerRow { width: parent.width }
    }
}
