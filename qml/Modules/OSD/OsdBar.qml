import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Item {
    id: root
    property string label: ""
    property real value: 0.0
    property bool muted: false

    Row {
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.s2

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.muted ? (root.label + " · mute") : root.label
            color: root.muted ? Theme.ink5 : Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            width: 72
        }

        Atoms.Bar {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 72 - pct.width - Theme.s2 * 2
            value: root.muted ? 0 : root.value
        }

        Text {
            id: pct
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.value * 100) + "%"
            color: root.muted ? Theme.ink5 : Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            font.features: {"tnum": 1}
            horizontalAlignment: Text.AlignRight
            width: 32
        }
    }
}
