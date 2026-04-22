import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PopupWindow {
    id: root
    //  ControlCenter: 380xauto (cap 720) popup top-right under bar.
    //  Panels: Quick toggles, Audio, Brightness, Power.
    property bool open_: false
    visible: open_

    implicitWidth: 380
    implicitHeight: Math.min(720, column.implicitHeight)
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-control"
    anchor.window: null

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
        }
        Grid {
            columns: 2
            rowSpacing: 0
            columnSpacing: 0
            width: parent.width
            ToggleTile { label: "wifi";      on: NetworkService.online; width: parent.width / 2 }
            ToggleTile { label: "bluetooth"; on: BluetoothService.powered; width: parent.width / 2; onToggled: (v) => BluetoothService.setPowered(v) }
            ToggleTile { label: "dnd";       on: NotifService.dnd; width: parent.width / 2;       onToggled: (v) => NotifService.setDnd(v) }
            ToggleTile { label: "idle hold"; on: IdleService.inhibited; width: parent.width / 2;  onToggled: (v) => IdleService.setInhibited(v) }
        }
        AudioRow { width: parent.width }
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
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: PowerService.charging ? "charging" : (PowerService.onBattery ? "on battery" : "AC")
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
            }
        }
    }

    Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
}
