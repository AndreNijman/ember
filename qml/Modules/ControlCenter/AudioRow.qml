import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    property var node: null
    property bool isDefault: false

    implicitHeight: Theme.rowH
    implicitWidth: parent ? parent.width : 280

    readonly property string label: node ? (node.description || node.name || "") : ""
    readonly property real vol: node && node.audio ? node.audio.volume : 0.0
    readonly property bool isMuted: node && node.audio ? node.audio.muted : false

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s2

        Rectangle {
            width: 4; height: 4
            anchors.verticalCenter: parent.verticalCenter
            color: root.isDefault ? Theme.accent : "transparent"
        }

        Text {
            width: Math.min(implicitWidth, parent.width * 0.4)
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.isDefault ? Theme.ink8 : Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            elide: Text.ElideRight
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.isMuted ? "M" : Math.round(root.vol * 100) + "%"
            color: root.isMuted ? Theme.ink5 : Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
            font.features: {"tnum": 1}
            width: 32
        }

        Atoms.Slider {
            id: rowSlider
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            max_: 1.5
            onChanged: (v) => AudioService.setNodeVolume(root.node, v)
        }
    }

    Binding {
        target: rowSlider
        property: "value"
        value: root.vol
    }

    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.45
        onClicked: {
            if (!root.node) return
            if (root.node.isSink) AudioService.setDefaultSink(root.node)
            else AudioService.setDefaultSource(root.node)
        }
    }
}
