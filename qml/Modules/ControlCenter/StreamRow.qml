import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    property var node: null

    implicitHeight: Theme.rowH
    implicitWidth: parent ? parent.width : 280

    readonly property string appLabel: {
        if (!node) return ""
        var a = node.properties ? (node.properties["application.name"] || node.properties["application.process.binary"]) : ""
        return a || node.description || node.name || "stream"
    }
    readonly property real vol: node && node.audio ? node.audio.volume : 0.0
    readonly property bool isMuted: node && node.audio ? node.audio.muted : false

    // Hairline rail visually re-parents the stream rows under the device
    // they belong to without printing yet another dot.
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: Theme.s4
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Theme.hairW
        color: Theme.hairDim
        antialiasing: false
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s4 + Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s2

        Text {
            width: Math.min(implicitWidth, parent.width * 0.4)
            anchors.verticalCenter: parent.verticalCenter
            text: root.appLabel
            color: root.isMuted ? Theme.ink5 : Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
            elide: Text.ElideRight
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: AudioService.setNodeMuted(root.node, !root.isMuted)
            }
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
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            value: root.vol
            max_: 1.5
            onChanged: (v) => AudioService.setNodeVolume(root.node, v)
        }
    }
}
