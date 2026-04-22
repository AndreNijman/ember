import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    //  VpnConnector: 380xauto popout top-right under bar. Header, 4-tile
    //  telemetry grid (egress IP / TTFB / down / up), connect button,
    //  server footer. Driven entirely by VpnService.
    property bool open_: false
    visible: open_

    implicitWidth: 380
    implicitHeight: column.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-vpn"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: 32; right: 8 }
    exclusiveZone: 0

    function stateLabel() {
        const s = VpnService.state
        if (s === "on")            return "connected"
        if (s === "off")           return "disconnected"
        if (s === "connecting")    return "connecting…"
        if (s === "checking")      return "verifying…"
        if (s === "degraded")      return "degraded"
        if (s === "disconnecting") return "disconnecting…"
        return s
    }

    function stateColor() {
        const s = VpnService.state
        if (s === "on")       return Theme.accent
        if (s === "degraded") return Theme.err
        if (s === "off")      return Theme.ink6
        return Theme.warn
    }

    function formatRate(bps) {
        if (bps < 1024)    return bps.toFixed(0) + " B/s"
        if (bps < 1048576) return (bps / 1024).toFixed(1) + " KiB/s"
        return (bps / 1048576).toFixed(2) + " MiB/s"
    }

    Item {
        anchors.fill: parent
        focus: root.open_
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }

        Column {
            id: column
            width: parent.width
            spacing: 0

            // --- header ---
            Rectangle {
                width: parent.width; height: Theme.rowH; color: Theme.ink2
                antialiasing: false
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    text: "vpn"
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.s3
                    text: root.stateLabel()
                    color: root.stateColor()
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
            }

            Atoms.Hairline { width: parent.width }

            // --- degraded banner ---
            Rectangle {
                visible: VpnService.state === "degraded"
                width: parent.width
                height: visible ? Theme.rowH : 0
                color: Theme.ink0
                antialiasing: false

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    spacing: Theme.s2

                    Text {
                        text: "!"
                        color: Theme.err
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                    }
                    Text {
                        text: "egress " + (VpnService.egressIp || "unknown") + " != vps"
                        color: Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                }
            }

            Atoms.Hairline {
                width: parent.width
                visible: VpnService.state === "degraded"
            }

            // --- 4-tile telemetry grid ---
            Grid {
                width: parent.width
                columns: 2
                rowSpacing: 0
                columnSpacing: 0

                // egress IP
                Item {
                    width: parent.width / 2
                    height: Theme.rowH * 2
                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.s1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "egress ip"
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.t2xs
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: VpnService.egressIp || "--"
                            color: VpnService.egressIp === VpnService.vpsIp ? Theme.accent : Theme.ink8
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tmd
                        }
                    }
                }

                // TTFB
                Item {
                    width: parent.width / 2
                    height: Theme.rowH * 2
                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.s1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ttfb"
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.t2xs
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: VpnService.latencyMs < 0 ? "--" : (VpnService.latencyMs + " ms")
                            color: Theme.ink8
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tmd
                        }
                    }
                }

                // down
                Item {
                    width: parent.width / 2
                    height: Theme.rowH * 2
                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.s1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "down"
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.t2xs
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.formatRate(VpnService.rxRate)
                            color: Theme.ink8
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tmd
                        }
                    }
                }

                // up
                Item {
                    width: parent.width / 2
                    height: Theme.rowH * 2
                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.s1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "up"
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.t2xs
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.formatRate(VpnService.txRate)
                            color: Theme.ink8
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tmd
                        }
                    }
                }
            }

            Atoms.Hairline { width: parent.width }

            // --- primary button: connect / disconnect / reconnect ---
            Rectangle {
                id: btn
                width: parent.width
                height: Theme.tap
                color: btnMouse.containsMouse ? Theme.ink2 : Theme.ink1
                antialiasing: false

                property bool busy: VpnService.state === "connecting" ||
                                    VpnService.state === "disconnecting" ||
                                    VpnService.state === "checking"

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (VpnService.state === "off")       return "connect"
                        if (VpnService.state === "on")        return "disconnect"
                        if (VpnService.state === "degraded")  return "reconnect"
                        return "…"
                    }
                    color: root.stateColor()
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: btn.busy ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                    onClicked: { if (!btn.busy) VpnService.toggle() }
                }
            }

            Atoms.Hairline {
                width: parent.width
                visible: VpnService.state !== "off"
            }

            // --- force-quit: unconditional stop, for wedged tunnels ---
            Rectangle {
                id: forceBtn
                width: parent.width
                height: visible ? Theme.rowH : 0
                visible: VpnService.state !== "off"
                color: forceMouse.containsMouse ? Theme.ink2 : Theme.ink1
                antialiasing: false

                Text {
                    anchors.centerIn: parent
                    text: "force quit"
                    color: forceMouse.containsMouse ? Theme.err : Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }

                MouseArea {
                    id: forceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: VpnService.forceStop()
                }
            }

            Atoms.Hairline { width: parent.width }

            // --- footer: server info ---
            Item {
                width: parent.width
                height: Theme.rowH * 2

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.s3
                    spacing: Theme.s1

                    Text {
                        text: VpnService.vpsIp + ":443 — sydney"
                        color: Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                    Text {
                        text: "vless + reality · sni www.microsoft.com"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                    Text {
                        visible: VpnService.lastError.length > 0
                        text: VpnService.lastError
                        color: Theme.err
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                }
            }
        }
    }
}
