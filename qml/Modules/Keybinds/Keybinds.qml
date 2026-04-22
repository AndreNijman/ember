import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 880
    implicitHeight: 640
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-keybinds"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true }
    margins { top: 120 }
    exclusiveZone: 0

    readonly property var sections: [
        { title: "apps", binds: [
            { k: "SUPER T",            d: "terminal (kitty)" },
            { k: "SUPER B",            d: "browser (zen)" },
            { k: "SUPER C",            d: "claude code" },
            { k: "SUPER M",            d: "spotify" },
            { k: "SUPER D",            d: "discord" },
            { k: "ALT SPACE",          d: "launcher" },
            { k: "SUPER .",            d: "launcher" },
            { k: "SUPER K",            d: "control center" },
            { k: "SUPER N",            d: "notifications" },
            { k: "SUPER W",            d: "wallpaper picker" },
            { k: "SUPER /",            d: "this sheet" },
        ] },
        { title: "window", binds: [
            { k: "SUPER Q",            d: "close" },
            { k: "SUPER F",            d: "maximize" },
            { k: "SUPER SHIFT F",      d: "fullscreen" },
            { k: "SUPER SHIFT T",      d: "toggle float" },
            { k: "SUPER ,",            d: "toggle group" },
            { k: "SUPER R",            d: "toggle split" },
            { k: "SUPER CTRL F",       d: "reset size" },
        ] },
        { title: "focus", binds: [
            { k: "SUPER ← ↓ ↑ →",      d: "move focus" },
            { k: "SUPER SHIFT arrows",  d: "move window" },
            { k: "SUPER SHIFT H J K L", d: "move window" },
            { k: "SUPER CTRL arrows",   d: "focus monitor" },
            { k: "SUPER SHIFT CTRL arrows", d: "move to monitor" },
            { k: "SUPER HOME / END",   d: "first / last" },
        ] },
        { title: "workspace", binds: [
            { k: "SUPER 1 … 0",        d: "switch" },
            { k: "SUPER SHIFT 1 … 9",  d: "send to" },
            { k: "SUPER ALT 1 … 0",    d: "send to (alt)" },
            { k: "SUPER U / PgDn",     d: "next" },
            { k: "SUPER PgUp",         d: "prev" },
            { k: "SUPER CTRL ↓ / ↑",   d: "send + follow" },
            { k: "SUPER S",            d: "special (magic)" },
            { k: "CTRL SHIFT R",       d: "rename workspace" },
        ] },
        { title: "resize", binds: [
            { k: "SUPER - / =",        d: "width" },
            { k: "SUPER SHIFT - / =",  d: "height" },
            { k: "SUPER [ / ]",        d: "preselect L / R" },
        ] },
        { title: "media", binds: [
            { k: "XF86 VolUp / Down",  d: "volume" },
            { k: "XF86 Mute",          d: "mute" },
            { k: "XF86 MicMute",       d: "mic mute" },
            { k: "CTRL SUPER SPACE",   d: "play / pause" },
            { k: "CTRL SUPER = / -",   d: "next / prev track" },
            { k: "XF86 Brightness",    d: "brightness" },
        ] },
        { title: "screenshot", binds: [
            { k: "PRINT",              d: "output → clipboard" },
            { k: "CTRL PRINT",         d: "output save" },
            { k: "ALT PRINT",          d: "window save" },
            { k: "SUPER SHIFT S",      d: "region → clipboard" },
            { k: "SUPER SHIFT C",      d: "color picker" },
        ] },
        { title: "system", binds: [
            { k: "SUPER L",            d: "lock" },
            { k: "SUPER SHIFT E",      d: "exit hyprland" },
            { k: "CTRL ALT DEL",       d: "power menu" },
            { k: "SUPER SHIFT P",      d: "dpms toggle" },
            { k: "CTRL ALT C",         d: "clear notifications" },
        ] },
    ]

    Item {
        anchors.fill: parent
        focus: root.open_
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Slash || event.key === Qt.Key_Q) {
                root.open_ = false
                event.accepted = true
            }
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
                    text: "keybinds"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.s3
                    text: "⎋ close"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
            }

            Rectangle {
                width: parent.width
                height: root.height - Theme.rowH
                color: Theme.ink1
                antialiasing: false

                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.s3
                    contentWidth: width
                    contentHeight: grid.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: grid
                        width: parent.width
                        columns: 2
                        columnSpacing: Theme.s4
                        rowSpacing: Theme.s4

                        Repeater {
                            model: root.sections
                            delegate: Column {
                                required property var modelData
                                width: (grid.width - Theme.s4) / 2
                                spacing: 0

                                Rectangle {
                                    width: parent.width; height: Theme.rowH; color: Theme.ink0
                                    antialiasing: false
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.s2
                                        text: modelData.title
                                        color: Theme.accent
                                        font.family: Theme.fontUi
                                        font.pixelSize: Theme.tsm
                                    }
                                }

                                Repeater {
                                    model: modelData.binds
                                    delegate: Item {
                                        required property var modelData
                                        width: parent.width
                                        height: Theme.rowH - 4

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: Theme.s2
                                            text: modelData.k
                                            color: Theme.ink8
                                            font.family: Theme.fontUi
                                            font.pixelSize: Theme.txs
                                            width: parent.width * 0.5
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            anchors.rightMargin: Theme.s2
                                            text: modelData.d
                                            color: Theme.ink6
                                            font.family: Theme.fontUi
                                            font.pixelSize: Theme.txs
                                            horizontalAlignment: Text.AlignRight
                                            width: parent.width * 0.5
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
