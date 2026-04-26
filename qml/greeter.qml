// ember greeter — the QML side of cmd/aqs-greeter.
//
// Connects to $AQS_GREETER_SOCK exported by the parent binary, talks the
// newline protocol described in cmd/aqs-greeter/main.go.
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "Theme"

ShellRoot {
    id: app

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: win
                required property var modelData
                screen: modelData
                anchors { top: true; bottom: true; left: true; right: true }
                color: Theme.ink0
                exclusiveZone: 0
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "aqs-greeter"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                property bool isPrimary: modelData === Quickshell.screens[0]

                Item {
                    anchors.fill: parent
                    visible: win.isPrimary

                    Column {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: Theme.s8
                        anchors.bottomMargin: Theme.s8
                        spacing: Theme.s2

                        Text {
                            text: clock.timeText
                            color: Theme.ink8
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.t3xl
                            font.weight: Font.Light
                            font.features: {"tnum": 1}
                        }
                        Text {
                            text: clock.dateText
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.tmd
                        }
                    }

                    Column {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: Theme.s8
                        anchors.bottomMargin: Theme.s8
                        spacing: Theme.s3
                        width: 360

                        Text {
                            id: errLabel
                            visible: app.lastError.length > 0
                            text: app.lastError
                            color: Theme.err
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.txs
                            wrapMode: Text.WrapAnywhere
                            width: parent.width
                        }

                        Rectangle {
                            width: parent.width; height: 1; color: Theme.hairDim
                        }

                        Row {
                            spacing: Theme.s2
                            width: parent.width
                            Text {
                                text: "user"
                                color: Theme.ink5
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.tsm
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TextInput {
                                id: userField
                                width: 280
                                color: Theme.ink8
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.tsm
                                text: app.defaultUser
                                selectByMouse: true
                                cursorVisible: focus
                                Keys.onTabPressed: passField.forceActiveFocus()
                                Keys.onReturnPressed: passField.forceActiveFocus()
                            }
                        }

                        Row {
                            spacing: Theme.s2
                            width: parent.width
                            Text {
                                text: "pass"
                                color: Theme.ink5
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.tsm
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TextInput {
                                id: passField
                                width: 280
                                color: Theme.ink8
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.tsm
                                echoMode: TextInput.Password
                                passwordCharacter: "•"
                                selectByMouse: true
                                cursorVisible: focus
                                Keys.onReturnPressed: app.submit(userField.text, passField.text)
                            }
                        }

                        Row {
                            spacing: Theme.s4
                            anchors.right: parent.right
                            Text {
                                text: app.busy ? "authenticating…" : "⏎ login"
                                color: Theme.ink5
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.txs
                            }
                            Text {
                                text: "shutdown"
                                color: Theme.ink5
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.txs
                                MouseArea {
                                    anchors.fill: parent; anchors.margins: -Theme.s1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: app.send("power off")
                                }
                            }
                            Text {
                                text: "reboot"
                                color: Theme.ink5
                                font.family: Theme.fontUi
                                font.pixelSize: Theme.txs
                                MouseArea {
                                    anchors.fill: parent; anchors.margins: -Theme.s1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: app.send("power reboot")
                                }
                            }
                        }
                    }
                }

                Component.onCompleted: if (isPrimary) passField.forceActiveFocus()
            }
        }
    }

    property string defaultUser: Quickshell.env("USER") || ""
    property string lastError: ""
    property bool busy: false
    property bool authed: false

    function submit(user, pass) {
        if (busy) return
        if (user.length === 0 || pass.length === 0) {
            lastError = "username and password required"
            return
        }
        lastError = ""
        busy = true
        send("auth " + user + " " + pass)
    }

    function send(line) {
        sock.write(line + "\n")
    }

    Socket {
        id: sock
        path: Quickshell.env("AQS_GREETER_SOCK") || ""
        connected: path.length > 0
        parser: SplitParser {
            onRead: (line) => {
                var parts = line.split(" ")
                var verb = parts[0]
                var rest = line.substring(verb.length + 1)
                if (verb === "ok") {
                    if (!app.authed) {
                        app.authed = true
                        app.busy = false
                        app.send("start")
                    } else {
                        // start succeeded — greetd will replace us.
                    }
                } else if (verb === "err") {
                    app.busy = false
                    app.authed = false
                    app.lastError = rest
                } else if (verb === "prompt") {
                    app.lastError = rest
                }
            }
        }
    }

    QtObject {
        id: clock
        property string timeText: ""
        property string dateText: ""
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            var hh = ("0" + d.getHours()).slice(-2)
            var mm = ("0" + d.getMinutes()).slice(-2)
            clock.timeText = hh + ":" + mm
            var days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            var months = ["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]
            clock.dateText = days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear()
        }
    }
}
