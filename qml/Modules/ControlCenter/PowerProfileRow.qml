import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  PowerProfileRow: header + 3-segment selector for power-profiles-daemon.
    implicitHeight: Theme.rowH + Theme.tap

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
                text: "profile · " + PowerProfileService.active
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
        }

        Row {
            width: parent.width
            spacing: 0
            Repeater {
                model: PowerProfileService.profiles
                delegate: Rectangle {
                    required property string modelData
                    width: root.width / 3
                    height: Theme.tap
                    color: PowerProfileService.active === modelData ? Theme.ink2 : Theme.ink1
                    border.width: Theme.hairW
                    border.color: PowerProfileService.active === modelData ? Theme.accent : Theme.hair
                    antialiasing: false

                    Text {
                        anchors.centerIn: parent
                        text: modelData === "power-saver" ? "saver"
                            : modelData === "performance" ? "perf"
                            : modelData
                        color: PowerProfileService.active === modelData ? Theme.accent : Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfileService.set(modelData)
                    }
                }
            }
        }
    }
}
