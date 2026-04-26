import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    visible: LockService.locked
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#000000"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aqs-lock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property string pwd: ""
    property bool flashError: false
    property bool capsOn: false

    onVisibleChanged: if (visible) authZone.forceActiveFocus()

    Connections {
        target: LockService
        function onAuthFailed() {
            root.pwd = ""
            root.flashError = true
            flashTimer.restart()
        }
        function onUnlocked() { root.pwd = "" }
    }

    Timer {
        id: flashTimer
        interval: 320
        onTriggered: root.flashError = false
    }

    function _handleKey(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (!LockService.authenticating && root.pwd.length > 0)
                LockService.submit(root.pwd)
        } else if (event.key === Qt.Key_Backspace) {
            if (root.pwd.length > 0)
                root.pwd = root.pwd.substring(0, root.pwd.length - 1)
        } else if (event.key === Qt.Key_Delete) {
            root.pwd = ""
        } else if (event.text && event.text.length > 0
                   && event.key !== Qt.Key_Tab
                   && event.key !== Qt.Key_Escape) {
            root.pwd += event.text
            _detectCaps(event.text, event.modifiers)
        }
        event.accepted = true
    }

    function _detectCaps(ch, mods) {
        if (ch.length !== 1) return
        var upper = ch === ch.toUpperCase() && ch !== ch.toLowerCase()
        var lower = ch === ch.toLowerCase() && ch !== ch.toUpperCase()
        var shift = !!(mods & Qt.ShiftModifier)
        if ((upper && !shift) || (lower && shift)) capsOn = true
        else if ((lower && !shift) || (upper && shift)) capsOn = false
    }

    Column {
        id: stack
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Theme.s3
        anchors.topMargin: Theme.s8
        spacing: Theme.s3

        Text {
            text: Qt.formatDateTime(ClockService.now, "HH:mm")
            color: Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.t3xl
            font.weight: Font.Normal
        }
        Text {
            text: Qt.formatDate(ClockService.now, "dddd d MMMM yyyy")
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
        }

        Text {
            visible: MprisService.hasPlayer && MprisService.title.length > 0
            text: {
                var t = MprisService.title
                var a = MprisService.artist
                return a.length > 0 ? t + " · " + a : t
            }
            color: Theme.ink5
            font.family: Theme.fontDisplay
            font.italic: true
            font.pixelSize: Theme.tlg
            elide: Text.ElideRight
            width: 600
        }
    }

    Item {
        id: authZone
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.s3
        anchors.bottomMargin: Theme.s8
        width: 520
        height: Theme.tap
        focus: true
        Component.onCompleted: if (root.visible) forceActiveFocus()

        Keys.onPressed: (event) => root._handleKey(event)

        Row {
            id: dots
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: Theme.s2

            Repeater {
                model: root.pwd.length
                delegate: Rectangle {
                    width: 8
                    height: 8
                    radius: 0
                    color: root.flashError ? Theme.accent : Theme.ink8
                    antialiasing: false
                }
            }

            Rectangle {
                id: caret
                width: 2
                height: 20
                color: Theme.accent
                antialiasing: false
                visible: caretBlink.on
            }

            Text {
                visible: root.capsOn
                anchors.verticalCenter: parent.verticalCenter
                text: "^"
                color: Theme.warn
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }

        Timer {
            id: caretBlink
            property bool on: true
            interval: 520
            running: root.visible
            repeat: true
            onTriggered: on = !on
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => { authZone.forceActiveFocus(); mouse.accepted = false }
        preventStealing: false
        propagateComposedEvents: true
    }
}
