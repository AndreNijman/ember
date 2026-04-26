import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2
    visible: SystemMonitorService.netRxBps + SystemMonitorService.netTxBps > 1024

    Text {
        id: label
        anchors.centerIn: parent
        text: "↓" + SystemMonitorService.formatRate(SystemMonitorService.netRxBps) +
              " ↑" + SystemMonitorService.formatRate(SystemMonitorService.netTxBps)
        color: Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
}
