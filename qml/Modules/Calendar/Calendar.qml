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
        // Re-issue the gcalcli range whenever the visible month changes so
        // grid markers + agenda cover the month being viewed plus a small
        // forward buffer for the agenda list.
        var first = new Date(viewYear, viewMonth, 1)
        var last  = new Date(viewYear, viewMonth + 1, 1)
        var fmt = function(d) {
            return d.getFullYear() + "-" +
                   ("0" + (d.getMonth() + 1)).slice(-2) + "-" +
                   ("0" + d.getDate()).slice(-2)
        }
        _gcal.environment = ({
            "AQS_FROM": fmt(first),
            "AQS_TO":   fmt(last),
        })
        _gcal.running = true
    }

    function _prevMonth() {
        var d = new Date(viewYear, viewMonth - 1, 1)
        viewDate = d; viewMonth = d.getMonth(); viewYear = d.getFullYear()
        _loadEvents()
    }
    function _nextMonth() {
        var d = new Date(viewYear, viewMonth + 1, 1)
        viewDate = d; viewMonth = d.getMonth(); viewYear = d.getFullYear()
        _loadEvents()
    }

    // Map "YYYY-MM-DD" -> array of events on that day. Drives the grid
    // event-dot indicator + the agenda list filter when a day is picked.
    property var eventsByDate: ({})
    property string selectedDate: ""

    // Agenda below the grid: when a day is picked, show only that day's
    // events; otherwise show the next 20 events visible in this month.
    property var filteredEvents: {
        if (selectedDate.length > 0) return eventsByDate[selectedDate] || []
        return events.slice(0, 20)
    }

    Process {
        id: _gcal
        command: ["sh", "-c",
            "gcalcli agenda --tsv --nocolor --details=calendar \"$AQS_FROM\" \"$AQS_TO\" 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                // gcalcli columns: start_date | start_time | end_date |
                // end_time | title | calendar. First row is the header
                // unless we explicitly turn it off, so skip rows whose
                // first cell isn't an ISO date (cheaper than --no-header
                // which not all gcalcli builds expose).
                var lines = (this.text || "").split("\n")
                var evts = []
                var byDate = {}
                var dateRe = /^\d{4}-\d{2}-\d{2}$/
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t")
                    if (parts.length < 4) continue
                    var date = parts[0] || ""
                    if (!dateRe.test(date)) continue
                    var rawTitle = parts[4] || ""
                    // Drop placeholder rows: 'free time' style busy blocks
                    // sync as '(No title)' from Google. The calendar name
                    // alone is rarely informative on its own, so skip.
                    if (rawTitle === "(No title)" || rawTitle === "") continue
                    var ev = {
                        date:     date,
                        time:     parts[1] || "",
                        endDate:  parts[2] || "",
                        endTime:  parts[3] || "",
                        title:    rawTitle,
                        calendar: parts[5] || "",
                    }
                    evts.push(ev)
                    if (!byDate[date]) byDate[date] = []
                    byDate[date].push(ev)
                }
                root.events = evts
                root.eventsByDate = byDate
            }
        }
    }

    property bool addOpen: false

    Process {
        id: _add
        command: ["true"]
        onExited: { root.addOpen = false; root._loadEvents() }
    }

    function _addEvent(title, when) {
        if (!title || title.length === 0) return
        _add.command = ["sh", "-c", "gcalcli add --title \"$AQS_TITLE\" --when \"$AQS_WHEN\" --duration 60 --noprompt"]
        _add.environment = ({ "AQS_TITLE": title, "AQS_WHEN": when || "today 18:00" })
        _add.running = true
    }

    // Re-bound to ClockService.now so the today underline rolls over at
    // midnight without requiring a shell restart.
    property var _today: ClockService.now
    property int _todayDay:   _today.getDate()
    property int _todayMonth: _today.getMonth()
    property int _todayYear:  _today.getFullYear()

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
                    height: 32
                    visible: index >= grid.offset

                    property int dayNum: index - grid.offset + 1
                    property string dateKey: root.viewYear + "-" +
                        ("0" + (root.viewMonth + 1)).slice(-2) + "-" +
                        ("0" + dayNum).slice(-2)
                    property bool isToday: dayNum === root._todayDay
                                           && root.viewMonth === root._todayMonth
                                           && root.viewYear === root._todayYear
                    property bool isSelected: root.selectedDate === dateKey
                    property var dayEvents: root.eventsByDate[dateKey] || []
                    property int dotCount: Math.min(dayEvents.length, 3)

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: parent.isSelected ? Theme.ink3
                             : (hover.containsMouse ? Qt.rgba(1,1,1,0.04) : "transparent")
                        border.width: parent.isSelected ? Theme.hairW : 0
                        border.color: Theme.accent
                        antialiasing: false
                        Behavior on color { ColorAnimation { duration: Theme.tFast } }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        text: parent.dayNum
                        color: parent.isToday ? Theme.accent : Theme.ink8
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        font.features: {"tnum": 1}
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        spacing: 2
                        visible: parent.dotCount > 0 && !parent.isToday
                        Repeater {
                            model: parent.parent.dotCount
                            delegate: Rectangle {
                                width: 3; height: 3
                                color: Theme.ink6
                                antialiasing: false
                            }
                        }
                    }
                    Rectangle {
                        visible: parent.isToday
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        width: parent.width - Theme.s2 * 2
                        height: 2
                        color: Theme.accent
                        antialiasing: false
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedDate =
                            root.selectedDate === parent.dateKey ? "" : parent.dateKey
                    }
                }
            }
        }

        Atoms.Hairline { width: parent.width }

        Column {
            width: parent.width
            visible: root.filteredEvents.length > 0
            Repeater {
                model: root.filteredEvents
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
            visible: root.filteredEvents.length === 0
            width: parent.width; height: Theme.rowH
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: root.selectedDate.length > 0 ? "no events that day" : "no events"
                color: Theme.ink5
                font.family: Theme.fontDisplay
                font.italic: true
                font.pixelSize: Theme.tsm
            }
        }

        Atoms.Hairline { width: parent.width }

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: root.addOpen ? "− cancel" : "+ add event"
                color: Theme.accent
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addOpen = !root.addOpen
                }
            }
        }

        Item {
            visible: root.addOpen
            width: parent.width
            height: visible ? addCol.implicitHeight + Theme.s2 * 2 : 0

            Column {
                id: addCol
                anchors.fill: parent
                anchors.margins: Theme.s2
                spacing: Theme.s2

                Atoms.Field {
                    id: titleField
                    width: parent.width
                    placeholderText: "title"
                }
                Atoms.Field {
                    id: whenField
                    width: parent.width
                    placeholderText: "when (e.g. 'today 18:00', 'tomorrow 9am', '2026-05-01 14:30')"
                    text: "today 18:00"
                    Keys.onReturnPressed: root._addEvent(titleField.text, whenField.text)
                }
                Row {
                    spacing: Theme.s3
                    anchors.right: parent.right
                    Text {
                        text: "cancel"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -Theme.s1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.addOpen = false; titleField.text = "" }
                        }
                    }
                    Text {
                        text: "save"
                        color: Theme.accent
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -Theme.s1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root._addEvent(titleField.text, whenField.text)
                        }
                    }
                }
            }
        }
    }
}
