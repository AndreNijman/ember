import QtQuick
import Quickshell.Io
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  PowerRow: four hairline-bordered action cells for lock / suspend /
    //  reboot / shutdown. Also holds a separate logout cell beneath.
    implicitHeight: Theme.tap * 2

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.s3
                text: "power"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
        }

        Grid {
            width: parent.width
            columns: 4
            rowSpacing: 0
            columnSpacing: 0

            PowerCell {
                width: parent.width / 4
                label: "lock"
                onActivated: Ipc.lockEngage()
            }
            PowerCell {
                width: parent.width / 4
                label: "suspend"
                onActivated: runner.exec(["systemctl", "suspend"])
            }
            PowerCell {
                width: parent.width / 4
                label: "reboot"
                onActivated: runner.exec(["systemctl", "reboot"])
            }
            PowerCell {
                width: parent.width / 4
                label: "off"
                danger: true
                onActivated: runner.exec(["systemctl", "poweroff"])
            }
        }

        Rectangle {
            width: parent.width
            height: Theme.tap
            color: Theme.ink1
            border.width: Theme.hairW
            border.color: Theme.hair
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
        function exec(cmd) {
            runner.command = cmd
            runner.running = true
        }
    }
}
