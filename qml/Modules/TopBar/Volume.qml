import QtQuick
import QtQuick.Controls
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
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
    }

    Menu {
        id: sinkMenu
        background: Rectangle {
            color: Theme.ink1
            border.width: Theme.hairW
            border.color: Theme.hair
            antialiasing: false
            radius: 0
        }
        Repeater {
            model: AudioService.sinks
            delegate: MenuItem {
                required property var modelData
                text: (AudioService.sink === modelData ? "· " : "  ") +
                      (modelData.description || modelData.name || "sink")
                onTriggered: AudioService.setDefaultSink(modelData)
                contentItem: Text {
                    text: parent ? parent.text : ""
                    color: AudioService.sink === modelData ? Theme.accent : Theme.ink7
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    leftPadding: Theme.s2
                    rightPadding: Theme.s3
                }
                background: Rectangle {
                    color: parent && parent.hovered ? Theme.ink2 : "transparent"
                    antialiasing: false
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) sinkMenu.popup()
            else if (mouse.button === Qt.MiddleButton) AudioService.toggleMute()
            else Ipc.toggleControl()
        }
    }
}
