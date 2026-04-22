import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 820
    implicitHeight: 620
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-wallpaper"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    property string selectedPath: ""

    onOpen_Changed: { if (open_) WallpaperService.refreshList() }

    Item {
        anchors.fill: parent
        focus: root.open_
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: Theme.hairW
            border.color: Theme.accent
            antialiasing: false
        }

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                width: parent.width; height: Theme.rowH; color: Theme.ink2
                antialiasing: false
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    text: "wallpaper"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.s3
                    text: WallpaperService.available.length + " · ws " + WallpaperService.currentWorkspace
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
            }

            Rectangle {
                width: parent.width
                height: root.height - Theme.rowH - Theme.tap - Theme.rowH
                color: Theme.ink1
                antialiasing: false

                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.s3
                    contentWidth: width
                    contentHeight: tiles.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: tiles
                        width: parent.width
                        columns: 4
                        rowSpacing: 1
                        columnSpacing: 1

                        Repeater {
                            model: WallpaperService.available
                            delegate: Tile {
                                required property var modelData
                                width: (tiles.width - 3) / 4
                                height: width * 0.62
                                path: modelData.path
                                active: root.selectedPath === modelData.path
                                onPicked: root.selectedPath = modelData.path
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width; height: Theme.tap; color: Theme.ink0
                antialiasing: false
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    spacing: Theme.s1
                    Repeater {
                        model: 10
                        delegate: WorkspaceCell {
                            required property int index
                            label: String(index + 1 === 10 ? 0 : index + 1)
                            assigned: WallpaperService.mapping[String(index + 1)] === root.selectedPath && root.selectedPath.length > 0
                            enabled: root.selectedPath.length > 0
                            onPicked: if (root.selectedPath.length > 0) WallpaperService.setForWorkspace(index + 1, root.selectedPath)
                        }
                    }
                    Rectangle { width: 1; height: Theme.rowH - 10; color: Theme.hair; anchors.verticalCenter: parent.verticalCenter }
                    WorkspaceCell {
                        label: "all"
                        wide: true
                        assigned: WallpaperService.mapping["all"] === root.selectedPath && root.selectedPath.length > 0
                        enabled: root.selectedPath.length > 0
                        onPicked: if (root.selectedPath.length > 0) WallpaperService.setAll(root.selectedPath)
                    }
                }
            }

            Rectangle {
                width: parent.width; height: Theme.rowH; color: Theme.ink0
                antialiasing: false
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    text: root.selectedPath.length === 0 ? "pick an image, then assign to a workspace" : root.selectedPath.substring(root.selectedPath.lastIndexOf("/") + 1)
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    elide: Text.ElideMiddle
                    width: parent.width - Theme.s6
                }
            }
        }
    }
}
