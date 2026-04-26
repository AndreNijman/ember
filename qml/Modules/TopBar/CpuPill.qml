import QtQuick
import "../../Theme"
import "../../Services"

// Combined CPU + RAM pill. Drop label repetition — letters c / r prefix
// each value, period separator. Pill hides if both CPU and RAM widgets
// are disabled in settings.
Item {
    id: root
    visible: SettingsService.barShowCpu || SettingsService.barShowRam
    implicitHeight: Theme.barH
    implicitWidth: visible ? row.implicitWidth + Theme.s3 * 2 : 0

    property bool cpuHot: SystemMonitorService.cpuPct > 85
    property bool ramHot: SystemMonitorService.memPct > 90

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s2

        Text {
            visible: SettingsService.barShowCpu
            text: "c " + Math.round(SystemMonitorService.cpuPct) + "%"
            color: root.cpuHot ? Theme.err : Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            font.features: {"tnum": 1}
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
        Text {
            visible: SettingsService.barShowCpu && SettingsService.barShowRam
            text: "·"
            color: Theme.ink5
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: SettingsService.barShowRam
            text: "r " + Math.round(SystemMonitorService.memPct) + "%"
            color: root.ramHot ? Theme.err : Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            font.features: {"tnum": 1}
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
    }
}
