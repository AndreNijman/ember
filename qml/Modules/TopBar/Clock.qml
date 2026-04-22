import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            var d = ClockService.now
            var days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            return days[d.getDay()] + " " + d.getDate() + " " + ClockService.timeText
        }
        color: Theme.ink8
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Ipc.toggleCalendar()
    }
}
