pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property var entries: []
    property string query: ""
    property var results: filtered(query)
    property var _freq: ({})

    signal ranUsed(string id)

    function refresh() { _scan.running = true }
    function launch(id) {
        for (var i = 0; i < entries.length; i++) {
            if (entries[i].id === id) {
                _run.command = ["sh", "-c", entries[i].exec]
                _run.running = true
                _bumpFreq(id)
                root.ranUsed(id)
                return
            }
        }
    }

    function _bumpFreq(id) {
        if (!_freq[id]) _freq[id] = { count: 0, last: 0 }
        _freq[id].count++
        _freq[id].last = Date.now()
        _saveFreq.running = true
    }

    function recentApps() {
        var list = []
        for (var id in _freq) {
            for (var i = 0; i < entries.length; i++) {
                if (entries[i].id === id) {
                    list.push({ entry: entries[i], freq: _freq[id] })
                    break
                }
            }
        }
        list.sort(function(a, b) {
            if (a.freq.last !== b.freq.last) return b.freq.last - a.freq.last
            return b.freq.count - a.freq.count
        })
        var res = []
        for (var j = 0; j < list.length && j < 20; j++) res.push(list[j].entry)
        return res
    }

    function filtered(q) {
        if (!q || q.length === 0) return recentApps().length > 0 ? recentApps() : entries.slice(0, 50)
        if (q.startsWith("=") || q.startsWith(">") || q.startsWith(":") || q.startsWith(";") || q.startsWith("/") || q.startsWith("?")) return []
        var lq = q.toLowerCase()
        var out = []
        for (var i = 0; i < entries.length; i++) {
            var e = entries[i]
            var name = (e.name || "").toLowerCase()
            var boost = (_freq[e.id] && _freq[e.id].count) ? _freq[e.id].count * 5 : 0
            if (name.indexOf(lq) === 0) { out.push({entry: e, score: 100 + boost}); continue }
            if (name.indexOf(lq) >= 0) { out.push({entry: e, score: 60 + boost}); continue }
            var kw = (e.keywords || "").toLowerCase()
            if (kw.indexOf(lq) >= 0) out.push({entry: e, score: 40 + boost})
        }
        out.sort(function(a, b) { return b.score - a.score })
        var res = []
        for (var j = 0; j < out.length && j < 50; j++) res.push(out[j].entry)
        return res
    }

    property Process _scan: Process {
        command: ["sh", "-c", "for d in /usr/share/applications /usr/local/share/applications /var/lib/flatpak/exports/share/applications \"$HOME/.local/share/flatpak/exports/share/applications\" \"$HOME/.local/share/applications\"; do [ -d \"$d\" ] || continue; for f in \"$d\"/*.desktop; do [ -e \"$f\" ] || continue; awk -F= 'BEGIN{inmain=0; name=\"\"; exe=\"\"; kw=\"\"; ic=\"\"; nd=0; hd=0; tp=\"Application\"} /^\\[Desktop Entry\\]/{inmain=1; next} /^\\[/{inmain=0; next} inmain && /^Name=/ && name==\"\" {sub(/^Name=/,\"\"); name=$0} inmain && /^Exec=/ && exe==\"\" {sub(/^Exec=/,\"\"); exe=$0} inmain && /^Keywords=/{sub(/^Keywords=/,\"\"); kw=$0} inmain && /^Icon=/ && ic==\"\" {sub(/^Icon=/,\"\"); ic=$0} inmain && /^NoDisplay=/{nd=($2==\"true\")} inmain && /^Hidden=/{hd=($2==\"true\")} inmain && /^Type=/{tp=$2} END{if(name && exe && !nd && !hd && tp==\"Application\") printf \"%s\\t%s\\t%s\\t%s\\t%s\\n\", FILENAME, name, exe, kw, ic}' \"$f\"; done; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (this.text || "").split("\n")
                var dedup = {}
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].split("\t")
                    if (p.length < 3) continue
                    var path = p[0]
                    var id = path.substring(path.lastIndexOf("/") + 1)
                    dedup[id] = {
                        id: id,
                        name: p[1],
                        exec: (p[2] || "").replace(/%[a-zA-Z]/g, "").trim(),
                        keywords: p[3] || "",
                        icon: p[4] || "",
                        tier: 0
                    }
                }
                var list = []
                for (var k in dedup) list.push(dedup[k])
                list.sort(function(a, b) {
                    var na = (a.name || "").toLowerCase()
                    var nb = (b.name || "").toLowerCase()
                    return na < nb ? -1 : na > nb ? 1 : 0
                })
                root.entries = list
            }
        }
    }
    property Process _run: Process { command: ["true"] }

    property Process _loadFreq: Process {
        command: ["cat", Qt.resolvedUrl("").replace("file://", "").replace(/\/qml\/Services\/$/, "") + "/.cache/launcher.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root._freq = JSON.parse(this.text || "{}") } catch(e) { root._freq = {} }
            }
        }
    }
    property Process _saveFreq: Process {
        command: ["true"]
        function save() {
            var path = (Qt.application.arguments && Qt.application.arguments[0] || "").replace(/[^/]*$/, "")
            _saveFreq.command = ["sh", "-c", "mkdir -p ~/.cache/aqs && echo '" + JSON.stringify(root._freq).replace(/'/g, "'\\''") + "' > ~/.cache/aqs/launcher.json"]
            _saveFreq.running = true
        }
    }

    Component.onCompleted: {
        _loadFreq.command = ["sh", "-c", "cat ~/.cache/aqs/launcher.json 2>/dev/null || echo '{}'"]
        _loadFreq.running = true
        refresh()
    }

    onRanUsed: _saveFreq.save()
}
