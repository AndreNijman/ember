import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: row.implicitWidth + Theme.s3 * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s2

        Rectangle {
            visible: NotifService.items.length > 0 && !NotifService.dnd
            width: 4; height: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.accent
            antialiasing: false
        }
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: {
                var d = ClockService.now
                var days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
                return days[d.getDay()] + " " + d.getDate() + " " + ClockService.timeText
            }
            color: Theme.ink8
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.tmd
            font.features: {"tnum": 1}
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Ipc.toggleCalendar()
    }
}
