import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  Battery composite: percent as a numeric cell. Accent when charging,
    //  err color when <10%, ink7 otherwise.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            var pct = Math.round(PowerService.percent * 100)
            return pct + "%" + (PowerService.charging ? "+" : "")
        }
        color: {
            if (PowerService.charging) return Theme.accent
            if (PowerService.percent < 0.1) return Theme.err
            return Theme.ink7
        }
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
