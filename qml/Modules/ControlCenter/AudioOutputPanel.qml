import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 380

    Column {
        id: col
        width: parent.width
        spacing: 0

        Item {
            width: parent.width
            height: Theme.rowH
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                spacing: Theme.s2
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "OUTPUT"
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.t2xs
                    font.letterSpacing: 0.08 * Theme.t2xs
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: AudioService.muted ? "MUTE" : Math.round(AudioService.volume * 100) + "%"
                    color: AudioService.muted ? Theme.ink5 : Theme.ink7
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.t2xs
                }
            }
        }

        Item {
            width: parent.width
            height: Theme.rowH
            Atoms.Slider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                value: AudioService.volume
                max_: 1.5
                onChanged: (v) => AudioService.setVolume(v)
            }
        }

        Repeater {
            model: AudioService.sinks
            AudioRow {
                width: root.width
                node: modelData
                isDefault: AudioService.sink === modelData
            }
        }
    }
}
