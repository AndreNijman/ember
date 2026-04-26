import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: SettingsService.barShowRam
    implicitHeight: Theme.barH
    implicitWidth: visible ? label.implicitWidth + Theme.s3 * 2 : 0

    Text {
        id: label
        anchors.centerIn: parent
        text: "ram " + Math.round(SystemMonitorService.memPct) + "%"
        color: SystemMonitorService.memPct > 90 ? Theme.err : Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
}
