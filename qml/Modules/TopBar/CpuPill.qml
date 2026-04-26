import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: SettingsService.barShowCpu
    implicitHeight: Theme.barH
    implicitWidth: visible ? label.implicitWidth + Theme.s3 * 2 : 0

    Text {
        id: label
        anchors.centerIn: parent
        text: "cpu " + Math.round(SystemMonitorService.cpuPct) + "%"
        color: SystemMonitorService.cpuPct > 85 ? Theme.err : Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
}
