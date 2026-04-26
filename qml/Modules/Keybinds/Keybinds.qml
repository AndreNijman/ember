import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms

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

    property string bindsPath: (Quickshell.env("AQS_BINDS_FILE")
        || ((Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config"))
            + "/hypr/aqs/binds.conf"))

    property var sections: []

    onOpen_Changed: {
        if (open_) bindsFile.reload()
        else searchQuery = ""
    }

    FileView {
        id: bindsFile
        path: root.bindsPath
        blockLoading: false
        onLoaded: root.sections = root._parse(this.text())
        onLoadFailed: root.sections = []
    }

    function _parse(text) {
        if (!text || text.length === 0) return []
        var lines = text.split("\n")
        var sectionRe  = /^\s*#\s*=+\s*(.+?)\s*=*\s*$/
        var bindRe     = /^\s*(bind[a-z]*)\s*=\s*(.*)$/
        var groups = []
        var current = { title: "general", binds: [] }
        function push() {
            if (current.binds.length > 0) groups.push(current)
        }
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var sm = sectionRe.exec(line)
            if (sm) {
                push()
                current = { title: sm[1].toLowerCase(), binds: [] }
                continue
            }
            var bm = bindRe.exec(line)
            if (!bm) continue
            var rest = bm[2]
            var parts = rest.split(",").map(function(s) { return s.trim() })
            if (parts.length < 3) continue
            var mods = parts[0]
            var key  = parts[1]
            var action = parts[2]
            var args = parts.slice(3).join(", ")
            var k = (mods.length > 0 ? mods + " " : "") + key
            var d = args.length > 0 ? action + " " + args : action
            // Trim noisy `exec` prefix.
            d = d.replace(/^exec\s+/, "")
            current.binds.push({ k: k.toUpperCase(), d: d })
        }
        push()
        return groups
    }

    property string searchQuery: ""

    function filteredSections() {
        if (!searchQuery || searchQuery.length === 0) return sections
        var q = searchQuery.toLowerCase()
        var out = []
        for (var i = 0; i < sections.length; i++) {
            var s = sections[i]
            var filtered = []
            for (var j = 0; j < s.binds.length; j++) {
                var b = s.binds[j]
                if (b.k.toLowerCase().indexOf(q) >= 0 || b.d.toLowerCase().indexOf(q) >= 0)
                    filtered.push(b)
            }
            if (filtered.length > 0)
                out.push({ title: s.title, binds: filtered })
        }
        return out
    }

    Item {
        anchors.fill: parent
        focus: root.open_
        Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Slash) {
                searchInput.forceActiveFocus()
                event.accepted = true
            } else if (event.key === Qt.Key_Q && !searchInput.activeFocus) {
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

            Atoms.Field {
                id: searchInput
                width: parent.width
                placeholderText: "/ search keybinds"
                onTextChanged: root.searchQuery = text
                Keys.onEscapePressed: (event) => {
                    text = ""
                    parent.parent.forceActiveFocus()
                    event.accepted = true
                }
            }

            Rectangle {
                width: parent.width
                height: root.height - Theme.rowH - searchInput.height
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
                            model: root.filteredSections()
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
