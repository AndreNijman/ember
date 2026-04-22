import QtQuick
import "../../Theme"
import "../../Services"

Row {
    id: root
    visible: TrayService.items.length > 0
    spacing: Theme.s1

    Repeater {
        model: TrayService.items
        delegate: Item {
            required property var modelData
            width: 16
            height: Theme.barH
            Image {
                id: ico
                anchors.centerIn: parent
                width: 16; height: 16
                source: modelData.icon ? "image://icon/" + modelData.icon : ""
                sourceSize: Qt.size(16, 16)
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !ico.visible
                text: (modelData.title || "·").charAt(0)
                color: Theme.ink6
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
            }
        }
    }
}
