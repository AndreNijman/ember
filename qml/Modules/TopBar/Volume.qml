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
        text: AudioService.muted ? "vol mute" : ("vol " + Math.round(AudioService.volume * 100) + "%")
        color: AudioService.muted ? Theme.ink5 : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
    MouseArea { anchors.fill: parent; onClicked: Ipc.toggleControl() }
}
