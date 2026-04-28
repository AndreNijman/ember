import QtQuick
import "../../Theme"
import "../../Services"

// Compact Claude Code usage pill: 5h block (pct + reset) and weekly (pct + reset).
// Limits are cost-based — tune EMBER_CLAUDE_MAX_5H_COST / EMBER_CLAUDE_MAX_WEEK_COST
// in the environment to match your plan.
Item {
    id: root
    visible: ClaudeUsageService.valid
    implicitHeight: Theme.barH
    implicitWidth: visible ? row.implicitWidth + Theme.s3 * 2 : 0

    function _color(pct) {
        if (pct >= 80) return Theme.err
        if (pct >= 50) return Theme.warn
        return Theme.ink5
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s2

        Text {
            text: "cl"
            color: Theme.ink4
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: ClaudeUsageService.hour5Pct.toFixed(1) + "%"
            color: root._color(ClaudeUsageService.hour5Pct)
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            font.features: {"tnum": 1}
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
        Text {
            text: ClaudeUsageService.hour5ResetLabel
            color: Theme.ink4
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "·"
            color: Theme.ink4
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: ClaudeUsageService.weekPct.toFixed(1) + "%"
            color: root._color(ClaudeUsageService.weekPct)
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            font.features: {"tnum": 1}
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
        Text {
            text: ClaudeUsageService.weekResetLabel
            color: Theme.ink4
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
