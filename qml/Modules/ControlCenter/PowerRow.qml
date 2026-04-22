import QtQuick
import Quickshell.Io
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: expanded ? expandedH : Theme.tap
    property bool expanded: false
    property int expandedH: Theme.tap + Theme.tap + Theme.tap

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.tap
            color: Theme.ink1
            border.width: Theme.hairW
            border.color: Theme.hair
            antialiasing: false

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "power"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                }
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: root.expanded ? "‹" : "›"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.tmd
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expanded = !root.expanded
            }
        }

        Grid {
            visible: root.expanded
            width: parent.width
            columns: 4
            rowSpacing: 0; columnSpacing: 0

            PowerCell {
                width: parent.width / 4; label: "lock"
                onActivated: Ipc.lockEngage()
            }
            PowerCell {
                width: parent.width / 4; label: "suspend"
                onActivated: runner.exec(["systemctl", "suspend"])
            }
            PowerCell {
                width: parent.width / 4; label: "reboot"
                holdConfirm: true
                onActivated: runner.exec(["systemctl", "reboot"])
            }
            PowerCell {
                width: parent.width / 4; label: "off"
                danger: true; holdConfirm: true
                onActivated: runner.exec(["systemctl", "poweroff"])
            }
        }

        Rectangle {
            visible: root.expanded
            width: parent.width; height: Theme.tap
            color: Theme.ink1
            border.width: Theme.hairW; border.color: Theme.hair
            antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "logout"
                color: Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: runner.exec(["hyprctl", "dispatch", "exit"])
            }
        }
    }

    Process {
        id: runner
        command: ["true"]
        function exec(cmd) { runner.command = cmd; runner.running = true }
    }
}
