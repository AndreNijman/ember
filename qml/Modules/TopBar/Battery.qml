import QtQuick
import QtQuick.Controls
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    function _formatTime(sec) {
        if (!sec || sec <= 0) return "—"
        var h = Math.floor(sec / 3600)
        var m = Math.floor((sec % 3600) / 60)
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

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
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
    }

    ToolTip {
        id: tip
        visible: hover.containsMouse
        delay: 350
        text: PowerService.charging
            ? "charging · " + root._formatTime(PowerService.timeSec) + " to full"
            : (PowerService.full
               ? "full"
               : root._formatTime(PowerService.timeSec) + " remaining")
        background: Rectangle {
            color: Theme.ink2
            border.width: Theme.hairW
            border.color: Theme.hair
            antialiasing: false
            radius: 0
        }
        contentItem: Text {
            text: tip.text
            color: Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Ipc.toggleControl()
    }
}
