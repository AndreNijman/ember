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
            var pct = Math.round(PowerService.percent * 100)
            return "bat " + pct + "%" + (PowerService.charging ? " chg" : "")
        }
        color: {
            if (PowerService.charging) return Theme.accent
            if (PowerService.percent < 0.1) return Theme.err
            return Theme.ink7
        }
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
    MouseArea { anchors.fill: parent; onClicked: Ipc.toggleControl() }
}
