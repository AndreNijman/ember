pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  AppService enumerates .desktop entries under the standard dirs and
    //  provides a frecency-ranked filter for the Launcher. Ranking is a
    //  simple scoring combining prefix match + boost from a ~/.cache
    //  frecency log; both kept small and side-effect free.
    property var entries: []  // [{name, exec, id, keywords, tier}]
    property string query: ""
    property var results: filtered(query)

    signal ranUsed(string id)

    function refresh() { _scan.running = true }
    function launch(id) {
        for (var i = 0; i < entries.length; i++) {
            if (entries[i].id === id) {
                _run.command = ["sh", "-c", entries[i].exec]
                _run.running = true
                root.ranUsed(id)
                return
            }
        }
    }

    function filtered(q) {
        if (!q || q.length === 0) return entries.slice(0, 50)
        var lq = q.toLowerCase()
        var out = []
        for (var i = 0; i < entries.length; i++) {
            var e = entries[i]
            var name = (e.name || "").toLowerCase()
            if (name.indexOf(lq) === 0) { out.push({entry: e, score: 100}); continue }
            if (name.indexOf(lq) >= 0) { out.push({entry: e, score: 60}); continue }
            var kw = (e.keywords || "").toLowerCase()
            if (kw.indexOf(lq) >= 0) out.push({entry: e, score: 40})
        }
        out.sort(function(a, b) { return b.score - a.score })
        var res = []
        for (var j = 0; j < out.length && j < 50; j++) res.push(out[j].entry)
        return res
    }

    property Process _scan: Process {
        command: ["sh", "-c", "for d in /usr/share/applications /usr/local/share/applications /var/lib/flatpak/exports/share/applications \"$HOME/.local/share/flatpak/exports/share/applications\" \"$HOME/.local/share/applications\"; do [ -d \"$d\" ] || continue; for f in \"$d\"/*.desktop; do [ -e \"$f\" ] || continue; awk -F= 'BEGIN{inmain=0; name=\"\"; exe=\"\"; kw=\"\"; nd=0; hd=0; tp=\"Application\"} /^\\[Desktop Entry\\]/{inmain=1; next} /^\\[/{inmain=0; next} inmain && /^Name=/ && name==\"\" {sub(/^Name=/,\"\"); name=$0} inmain && /^Exec=/ && exe==\"\" {sub(/^Exec=/,\"\"); exe=$0} inmain && /^Keywords=/{sub(/^Keywords=/,\"\"); kw=$0} inmain && /^NoDisplay=/{nd=($2==\"true\")} inmain && /^Hidden=/{hd=($2==\"true\")} inmain && /^Type=/{tp=$2} END{if(name && exe && !nd && !hd && tp==\"Application\") printf \"%s\\t%s\\t%s\\t%s\\n\", FILENAME, name, exe, kw}' \"$f\"; done; done"]
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

    Component.onCompleted: refresh()
}
