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

    implicitWidth: 460
    implicitHeight: Math.min(560, column.implicitHeight)
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; left: true }
    margins { top: 0; left: 0 }
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

        // header
        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "settings"
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

        Section { title: "IDLE" }

        SettingRow {
            label: "screen off after"
            value: SettingsService.dpmsTimeoutSec + " s"
            input: Atoms.Field {
                width: 80
                text: SettingsService.dpmsTimeoutSec
                inputMethodHints: Qt.ImhDigitsOnly
                onEditingFinished: SettingsService.set("dpmsTimeoutSec", text)
            }
        }
        SettingRow {
            label: "auto-lock after"
            value: SettingsService.lockTimeoutSec + " s"
            input: Atoms.Field {
                width: 80
                text: SettingsService.lockTimeoutSec
                inputMethodHints: Qt.ImhDigitsOnly
                onEditingFinished: SettingsService.set("lockTimeoutSec", text)
            }
        }

        Section { title: "NOTIFICATIONS" }

        SettingRow {
            label: "do not disturb (default)"
            input: Atoms.Toggle {
                on: SettingsService.dndDefault
                onToggled: (v) => SettingsService.set("dndDefault", v)
            }
        }

        Section { title: "BAR WIDGETS" }

        SettingRow {
            label: "show CPU pill"
            input: Atoms.Toggle {
                on: SettingsService.barShowCpu
                onToggled: (v) => SettingsService.set("barShowCpu", v)
            }
        }
        SettingRow {
            label: "show RAM pill"
            input: Atoms.Toggle {
                on: SettingsService.barShowRam
                onToggled: (v) => SettingsService.set("barShowRam", v)
            }
        }
        SettingRow {
            label: "show network pill"
            input: Atoms.Toggle {
                on: SettingsService.barShowNet
                onToggled: (v) => SettingsService.set("barShowNet", v)
            }
        }
        SettingRow {
            label: "show VPN pill"
            input: Atoms.Toggle {
                on: SettingsService.barShowVpn
                onToggled: (v) => SettingsService.set("barShowVpn", v)
            }
        }

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink0
            antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "config: ~/.config/aqs/settings.json"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
    }
}
