import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  Volume composite: percent in the bar. Muted -> ink5 + "M" suffix.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: AudioService.muted ? "mute" : (Math.round(AudioService.volume * 100) + "%")
        color: AudioService.muted ? Theme.ink5 : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
    MouseArea { anchors.fill: parent; onClicked: AudioService.toggleMute() }
}
