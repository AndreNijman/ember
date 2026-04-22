import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"

Item {
    id: root
    property var menuHandle: null
    property bool open_: false
    property int rightMargin: 8

    PanelWindow {
        id: backdrop
        visible: root.open_ && root.menuHandle !== null
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "aqs-traymenu-backdrop"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.open_ = false
        }
    }

    PanelWindow {
        id: menu
        visible: root.open_ && root.menuHandle !== null
        implicitWidth: 220
        implicitHeight: menuCol.implicitHeight
        color: Theme.ink1
        WlrLayershell.namespace: "aqs-traymenu"
        WlrLayershell.layer: WlrLayer.Overlay
        anchors { top: true; right: true }
        margins { top: 0; right: root.rightMargin }
        exclusiveZone: 0

        onVisibleChanged: {
            if (visible && root.menuHandle) root.menuHandle.updateLayout()
        }

        QsMenuOpener {
            id: opener
            menu: root.menuHandle
        }

        Column {
            id: menuCol
            width: parent.width
            spacing: 0

            Repeater {
                model: opener.children
                delegate: Item {
                    required property var modelData
                    width: menuCol.width
                    height: modelData.isSeparator ? Theme.hairW : Theme.rowH
                    visible: true

                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.fill: parent
                        color: Theme.hair
                        antialiasing: false
                    }

                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        color: itemHover.containsMouse && modelData.enabled ? Theme.ink2 : "transparent"
                        antialiasing: false

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.s3
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.s3
                            text: modelData.text || ""
                            color: modelData.enabled ? (itemHover.containsMouse ? Theme.ink8 : Theme.ink7) : Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tsm
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: itemHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (modelData.enabled) {
                                    modelData.sendTriggered()
                                    root.open_ = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
