import QtQuick
import QtQuick.Controls
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
            id: cell
            width: 16
            height: Theme.barH
            Image {
                id: ico
                anchors.centerIn: parent
                width: 16; height: 16
                source: modelData.icon || ""
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
            ToolTip {
                id: tip
                visible: hover.containsMouse && tipText.length > 0
                delay: 350
                text: tipText
                property string tipText: modelData.tooltipTitle || modelData.title || modelData.id || ""
                background: Rectangle {
                    color: Theme.ink2
                    border.width: Theme.hairW
                    border.color: Theme.hair
                    antialiasing: false
                    radius: 0
                }
                contentItem: Text {
                    text: tip.text
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.t2xs
                }
            }
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate()
                    } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                        var global = mapToGlobal(width / 2, 0)
                        var sw = Window.window ? Window.window.width : 1920
                        trayMenu.menuHandle = modelData.menu
                        trayMenu.rightMargin = Math.max(0, sw - global.x - 110)
                        trayMenu.open_ = !trayMenu.open_
                    }
                }
            }
        }
    }

    TrayMenu {
        id: trayMenu
    }
}
