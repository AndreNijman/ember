import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    //  AudioRow: label + slider bound to AudioService.volume.
    implicitHeight: Theme.rowH * 2
    implicitWidth: parent ? parent.width : 280

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s3
        spacing: Theme.s1
        Text {
            text: "audio · " + AudioService.sinkName
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
        }
        Atoms.Slider {
            width: parent.width
            value: AudioService.volume
            max_: 1.5
            onChanged: AudioService.setVolume(value)
        }
    }
}
