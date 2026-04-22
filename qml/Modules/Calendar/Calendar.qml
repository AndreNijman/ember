import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 320
    implicitHeight: col.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-calendar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; right: true }
    margins { top: 0; right: 0 }
    exclusiveZone: 0

    onVisibleChanged: if (visible) _focus.forceActiveFocus()
    Item {
        id: _focus; focus: true
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }

    property date viewDate: new Date()
    property int viewMonth: viewDate.getMonth()
    property int viewYear: viewDate.getFullYear()
    property var events: []

    Component.onCompleted: _loadEvents()
    onOpen_Changed: if (open_) _loadEvents()

    function _loadEvents() {
        _gcal.running = true
    }

    function _prevMonth() {
        var d = new Date(viewYear, viewMonth - 1, 1)
        viewDate = d; viewMonth = d.getMonth(); viewYear = d.getFullYear()
    }
    function _nextMonth() {
        var d = new Date(viewYear, viewMonth + 1, 1)
        viewDate = d; viewMonth = d.getMonth(); viewYear = d.getFullYear()
    }

    Process {
        id: _gcal
        command: ["sh", "-c", "gcalcli agenda --tsv --nocolor 2>/dev/null | head -20 || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (this.text || "").split("\n")
                var evts = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t")
                    if (parts.length >= 4) {
                        evts.push({
                            date: parts[0] || "",
                            time: parts[1] || "",
                            endTime: parts[3] || "",
                            title: parts[4] || parts[3] || ""
                        })
                    }
                }
                root.events = evts
            }
        }
    }

    property var _today: new Date()
    property int _todayDay: _today.getDate()
    property int _todayMonth: _today.getMonth()
    property int _todayYear: _today.getFullYear()

    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function _firstDayOfWeek(y, m) { return new Date(y, m, 1).getDay() }

    Column {
        id: col
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "‹"
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s2
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._prevMonth()
                    }
                }
                Item { width: Theme.s3; height: 1 }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var months = ["january", "february", "march", "april", "may", "june",
                                      "july", "august", "september", "october", "november", "december"]
                        return months[root.viewMonth] + " " + root.viewYear
                    }
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.s3
                text: "›"
                color: Theme.ink6
                font.family: Theme.fontUi
                font.pixelSize: Theme.tmd
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s2
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._nextMonth()
                }
            }
        }

        Row {
            width: parent.width
            Repeater {
                model: ["su", "mo", "tu", "we", "th", "fr", "sa"]
                delegate: Item {
                    required property string modelData
                    width: parent.width / 7
                    height: 20
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                    }
                }
            }
        }

        Grid {
            id: grid
            width: parent.width
            columns: 7
            property int offset: root._firstDayOfWeek(root.viewYear, root.viewMonth)
            property int days: root._daysInMonth(root.viewYear, root.viewMonth)

            Repeater {
                model: grid.offset + grid.days
                delegate: Item {
                    required property int index
                    width: grid.width / 7
                    height: 28
                    visible: index >= grid.offset

                    property int dayNum: index - grid.offset + 1
                    property bool isToday: dayNum === root._todayDay
                                           && root.viewMonth === root._todayMonth
                                           && root.viewYear === root._todayYear

                    Text {
                        anchors.centerIn: parent
                        text: parent.dayNum
                        color: parent.isToday ? Theme.accent : Theme.ink8
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        font.features: {"tnum": 1}
                    }
                    Rectangle {
                        visible: parent.isToday
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: parent.width - Theme.s2 * 2
                        height: 2
                        color: Theme.accent
                        antialiasing: false
                    }
                }
            }
        }

        Atoms.Hairline { width: parent.width }

        Column {
            width: parent.width
            visible: root.events.length > 0
            Repeater {
                model: root.events
                delegate: Item {
                    required property var modelData
                    width: parent.width
                    height: Theme.rowH
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.s3
                        anchors.rightMargin: Theme.s3
                        spacing: Theme.s2
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.time || ""
                            color: Theme.ink5
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.t2xs
                            font.features: {"tnum": 1}
                            width: 40
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.title || ""
                            color: Theme.ink7
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.txs
                            elide: Text.ElideRight
                            width: parent.width - 52
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.events.length === 0
            width: parent.width; height: Theme.rowH
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: "no events"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
    }
}
