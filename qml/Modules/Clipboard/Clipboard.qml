import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../Theme"
import "../../Atoms" as Atoms

PanelWindow {
    id: root
    property bool open_: false
    visible: open_

    implicitWidth: 480
    implicitHeight: Math.min(560, column.implicitHeight)
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-clipboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true }
    margins { top: 160 }
    exclusiveZone: 0

    property var entries: []
    property var _thumbs: ({})
    property int _thumbGen: 0

    onOpen_Changed: {
        if (open_) {
            _load.running = true
            searchInput.text = ""
            _focus.forceActiveFocus()
        }
    }

    Process {
        id: _load
        command: ["sh", "-c", "cliphist list 2>/dev/null | head -100"]
        property var _lines: []
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _load._lines.push(line) }
        }
        onExited: {
            var out = []
            var binaryIds = []
            for (var i = 0; i < _lines.length; i++) {
                var line = _lines[i]
                var tab = line.indexOf("\t")
                if (tab < 0) continue
                var id = line.substring(0, tab).trim()
                var content = line.substring(tab + 1)
                var isBinary = content.startsWith("[[ binary data")
                out.push({ clipId: id, text: isBinary ? content : content.substring(0, 200), isBinary: isBinary })
                if (isBinary) binaryIds.push(id)
            }
            root.entries = out
            if (binaryIds.length > 0) root._decodeThumbs(binaryIds)
        }
    }

    function _decodeThumbs(ids) {
        var cmds = []
        for (var i = 0; i < ids.length; i++) {
            var p = "/tmp/aqs-clip-" + ids[i] + ".png"
            cmds.push("cliphist decode " + ids[i] + " > " + p + " && echo " + ids[i] + ":" + p)
        }
        _thumbProc.command = ["sh", "-c", cmds.join("; ")]
        _thumbProc.running = true
    }

    Process {
        id: _thumbProc
        command: ["true"]
        property var _lines: []
        onRunningChanged: if (running) _lines = []
        stdout: SplitParser {
            onRead: (line) => { _thumbProc._lines.push(line) }
        }
        onExited: {
            var m = {}
            for (var k in root._thumbs) m[k] = root._thumbs[k]
            for (var i = 0; i < _thumbProc._lines.length; i++) {
                var line = _thumbProc._lines[i]
                var sep = line.indexOf(":")
                if (sep < 0) continue
                var id = line.substring(0, sep)
                var path = line.substring(sep + 1)
                m[id] = "file://" + path
            }
            root._thumbs = m
            root._thumbGen++
        }
    }

    Process {
        id: _paste
        command: ["true"]
    }

    Process {
        id: _delete
        command: ["true"]
        onExited: _load.running = true
    }

    Process {
        id: _wipe
        command: ["cliphist", "wipe"]
        onExited: { root.entries = []; root._thumbs = {}; root._thumbGen++; _load.running = true }
    }

    function paste(clipId) {
        _paste.command = ["sh", "-c", "cliphist decode " + clipId + " | wl-copy"]
        _paste.running = true
        root.open_ = false
    }

    function remove(clipId) {
        _delete.command = ["sh", "-c", "cliphist delete-query " + clipId]
        _delete.running = true
    }

    function thumbUrl(clipId) {
        void root._thumbGen
        return root._thumbs[clipId] || ""
    }

    property var filtered: {
        var q = searchInput.text.toLowerCase()
        if (!q || q.length === 0) return entries
        var out = []
        for (var i = 0; i < entries.length; i++) {
            if (entries[i].text.toLowerCase().indexOf(q) >= 0)
                out.push(entries[i])
        }
        return out
    }

    Column {
        id: column
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                text: "clipboard"
                color: Theme.ink8
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                spacing: Theme.s3
                Text {
                    text: "wipe"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: _wipe.running = true
                    }
                }
                Text {
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
        }

        Atoms.Field {
            id: searchInput
            width: parent.width
            placeholderText: "search clipboard"
            Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
            Keys.onReturnPressed: (event) => {
                if (root.filtered.length > 0)
                    root.paste(root.filtered[list.currentIndex].clipId)
                event.accepted = true
            }
            Keys.onUpPressed: { list.decrementCurrentIndex(); event.accepted = true }
            Keys.onDownPressed: { list.incrementCurrentIndex(); event.accepted = true }
        }

        ListView {
            id: list
            width: parent.width
            height: Math.min(440, contentHeight)
            clip: true
            model: root.filtered
            currentIndex: 0
            keyNavigationWraps: true

            delegate: Rectangle {
                required property var modelData
                required property int index
                width: list.width
                height: modelData.isBinary ? imgRow.height + Theme.s2 * 2 : Math.min(entryCol.implicitHeight + Theme.s2 * 2, Theme.rowH * 3)
                color: list.currentIndex === index ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
                clip: true

                Atoms.Strip {
                    orientation: Qt.Vertical
                    active: list.currentIndex === index
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }

                Item {
                    id: imgRow
                    visible: modelData.isBinary
                    anchors.left: parent.left; anchors.right: idLabel.left
                    anchors.leftMargin: Theme.s3; anchors.rightMargin: Theme.s2
                    anchors.top: parent.top; anchors.topMargin: Theme.s2
                    height: visible ? 80 : 0

                    Image {
                        id: thumb
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: 76
                        width: height * 1.5
                        fillMode: Image.PreserveAspectFit
                        source: root.thumbUrl(modelData.clipId)
                        asynchronous: true
                        sourceSize.height: 152
                    }
                    Text {
                        anchors.left: thumb.right
                        anchors.leftMargin: Theme.s2
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        font.italic: true
                    }
                }

                Column {
                    id: entryCol
                    visible: !modelData.isBinary
                    anchors.left: parent.left; anchors.right: idLabel.left
                    anchors.leftMargin: Theme.s3; anchors.rightMargin: Theme.s2
                    anchors.top: parent.top; anchors.topMargin: Theme.s2

                    Text {
                        text: modelData.text
                        color: Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        width: parent.width
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                Text {
                    id: idLabel
                    anchors.right: delBtn.left; anchors.rightMargin: Theme.s2
                    anchors.top: parent.top; anchors.topMargin: Theme.s2
                    text: "#" + modelData.clipId
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.t2xs
                    font.features: {"tnum": 1}
                }
                Text {
                    id: delBtn
                    anchors.right: parent.right; anchors.rightMargin: Theme.s3
                    anchors.top: parent.top; anchors.topMargin: Theme.s2
                    text: "×"
                    color: Theme.ink5
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.remove(modelData.clipId)
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width
                    height: Theme.hairW; color: Theme.hairDim
                    antialiasing: false
                }

                MouseArea {
                    anchors.left: parent.left; anchors.right: idLabel.left
                    anchors.top: parent.top; anchors.bottom: parent.bottom
                    onClicked: root.paste(modelData.clipId)
                }
            }
        }

        Rectangle {
            visible: root.filtered.length === 0
            width: parent.width; height: Theme.rowH * 2
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: root.entries.length === 0 ? "clipboard empty" : "no matches"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
        }

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink0
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                text: "⏎ paste   ↑↓ nav   ⎋ close"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
    }

    Item {
        id: _focus
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
    }
}
