import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 340
    implicitHeight: col.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-singbox"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: 32; right: 8 }
    exclusiveZone: 0

    onVisibleChanged: if (visible) {
        _focus.forceActiveFocus()
        if (SingBoxService.active) {
            SingBoxService._egressCheck.running = true
            SingBoxService._latencyCheck.running = true
        }
    }

    Item {
        id: _focus; focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    Column {
        id: col
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                text: "sing-box vpn"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                text: "×"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.tmd
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.open_ = false
                }
            }
        }

        Rectangle {
            visible: SingBoxService.state === "degraded"
            width: parent.width; height: Theme.rowH
            color: Theme.warn; antialiasing: false
            Text {
                anchors.centerIn: parent
                text: "tunnel degraded — egress check failed"
                color: Theme.accentFg
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }

        Grid {
            width: parent.width
            columns: 2
            rowSpacing: 0; columnSpacing: 0

            StatCell {
                width: parent.width / 2
                label: "egress"
                value: SingBoxService.egressIp || "—"
            }
            StatCell {
                width: parent.width / 2
                label: "latency"
                value: SingBoxService.latencyMs > 0 ? SingBoxService.latencyMs + " ms" : "—"
            }
            StatCell {
                width: parent.width / 2
                label: "↓ rate"
                value: SingBoxService.active ? SingBoxService.formatRate(SingBoxService.rxRate) : "—"
            }
            StatCell {
                width: parent.width / 2
                label: "↑ rate"
                value: SingBoxService.active ? SingBoxService.formatRate(SingBoxService.txRate) : "—"
            }
        }

        Atoms.Hairline { width: parent.width }

        Item {
            width: parent.width; height: Theme.rowH
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3; anchors.rightMargin: Theme.s3
                spacing: Theme.s2
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "total"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "↓" + SingBoxService.formatBytes(SingBoxService.rxBytes) + "  ↑" + SingBoxService.formatBytes(SingBoxService.txBytes)
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    font.features: {"tnum": 1}
                }
            }
        }

        Atoms.Hairline { width: parent.width }

        Rectangle {
            width: parent.width; height: Theme.tap
            color: connectHover.containsMouse ? Theme.ink2 : Theme.ink1
            border.width: Theme.hairW
            border.color: {
                if (SingBoxService.busy) return Theme.ink5
                if (SingBoxService.active) return Theme.err
                return Theme.ok
            }
            antialiasing: false

            Text {
                anchors.centerIn: parent
                text: {
                    if (SingBoxService.state === "connecting") return "connecting..."
                    if (SingBoxService.state === "disconnecting") return "disconnecting..."
                    if (SingBoxService.state === "checking") return "checking..."
                    if (SingBoxService.active) return "disconnect"
                    return "connect"
                }
                color: {
                    if (SingBoxService.busy) return Theme.ink5
                    if (SingBoxService.active) return Theme.err
                    return Theme.ok
                }
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            MouseArea {
                id: connectHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: SingBoxService.busy ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: SingBoxService.toggle()
            }
        }

        Atoms.Hairline { width: parent.width }

        Rectangle {
            width: parent.width; height: Theme.tap
            color: speedHover.containsMouse ? Theme.ink2 : Theme.ink1
            border.width: Theme.hairW
            border.color: Theme.hair
            antialiasing: false

            Text {
                anchors.centerIn: parent
                text: SingBoxService.speedRunning ? "running speedtest..." : "speedtest"
                color: SingBoxService.speedRunning ? Theme.ink5 : Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            MouseArea {
                id: speedHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: SingBoxService.speedRunning ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: SingBoxService.runSpeedtest()
            }
        }

        Item {
            visible: SingBoxService.speedResult.length > 0
            width: parent.width; height: Theme.rowH
            Text {
                anchors.centerIn: parent
                text: SingBoxService.speedResult
                color: Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
                font.features: {"tnum": 1}
            }
        }

        Atoms.Hairline { width: parent.width }

        Item {
            width: parent.width; height: Theme.rowH
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                text: "VLESS+REALITY · VPN_HOST:443"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
            }
        }
    }

    component StatCell: Rectangle {
        property string label: ""
        property string value: ""
        height: Theme.tap
        color: Theme.ink1
        border.width: Theme.hairW
        border.color: Theme.hair
        antialiasing: false
        Column {
            anchors.centerIn: parent
            spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: value
                color: Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                font.features: {"tnum": 1}
            }
        }
    }
}
