import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  Clock composite: HH:mm in the UI mono stack. Date tooltip on hover
    //  is deferred; the bar stays quiet by default.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: ClockService.timeText
        color: Theme.ink8
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
