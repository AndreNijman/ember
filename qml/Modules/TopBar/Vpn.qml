import QtQuick
import Quickshell.Io
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    property bool active: false

    Timer {
        interval: 3000; repeat: true; running: true
        onTriggered: _check.running = true
    }
    Component.onCompleted: _check.running = true

    Process {
        id: _check
        command: ["pgrep", "-x", "sing-box"]
        onExited: (code, status) => { root.active = (code === 0) }
    }

    Process {
        id: _toggle
        command: ["true"]
        function exec(cmd) { _toggle.command = cmd; _toggle.running = true }
        onExited: _check.running = true
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.active ? "vpn" : "vpn"
        color: root.active ? Theme.ok : Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.active)
                _toggle.exec(["sudo", "systemctl", "stop", "sing-box"])
            else
                _toggle.exec(["sudo", "systemctl", "start", "sing-box"])
        }
    }
}
