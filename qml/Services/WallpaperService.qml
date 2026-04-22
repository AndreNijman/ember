pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  WallpaperService: drives the awww-daemon backend and persists a
    //  per-workspace mapping to ~/.config/ember/wallpapers.json. On startup
    //  the daemon is spawned and the stored mapping for the active
    //  workspace is restored. Backend binary is `awww` (Arch's fork of
    //  swww) with transition-type=none per brief.

    property string home: ""
    readonly property string configDir:  home.length > 0 ? home + "/.config/ember"               : ""
    readonly property string configPath: home.length > 0 ? configDir + "/wallpapers.json"        : ""
    readonly property string picturesDir: home.length > 0 ? home + "/Pictures/Wallpapers"        : ""

    property var mapping: ({})
    property int currentWorkspace: 1
    property var available: []

    signal reloaded()

    function setForWorkspace(ws, path) {
        var m = Object.assign({}, root.mapping)
        m[String(ws)] = path
        root.mapping = m
        _persist()
        if (ws === "all" || Number(ws) === root.currentWorkspace) _apply(path)
    }

    function setAll(path) {
        var m = Object.assign({}, root.mapping)
        m["all"] = path
        root.mapping = m
        _persist()
        _apply(path)
    }

    function clearWorkspace(ws) {
        var m = Object.assign({}, root.mapping)
        delete m[String(ws)]
        root.mapping = m
        _persist()
        _restoreForWorkspace(root.currentWorkspace)
    }

    function onWorkspaceChanged(id) {
        root.currentWorkspace = id
        _restoreForWorkspace(id)
    }

    function refreshList() { if (home.length > 0) _ls.running = true }

    // --- internals -----------------------------------------------------

    property Process _home: Process {
        command: ["sh", "-c", "printf %s \"$HOME\""]
        stdout: StdioCollector {
            onStreamFinished: {
                root.home = (this.text || "").trim()
                _init.running = true
            }
        }
    }

    property Process _init: Process {
        command: ["sh", "-c", "mkdir -p \"$HOME/Pictures/Wallpapers\" \"$HOME/.config/ember\""]
        onExited: (code, status) => {
            _daemon.running = true
            _read.running = true
            _ls.running = true
        }
    }

    property Process _daemon: Process {
        command: ["sh", "-c", "pgrep -x awww-daemon >/dev/null || awww-daemon"]
    }

    property Process _img: Process { command: ["true"] }
    property Process _write: Process { command: ["true"] }

    property Process _read: Process {
        command: ["sh", "-c", "cat \"$HOME/.config/ember/wallpapers.json\" 2>/dev/null || printf '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var j = JSON.parse(this.text || "{}")
                    root.mapping = j || {}
                } catch (e) {
                    root.mapping = {}
                }
                _restoreForWorkspace(root.currentWorkspace)
                root.reloaded()
            }
        }
    }

    property Process _ls: Process {
        command: ["sh", "-c", "d=\"$HOME/Pictures/Wallpapers\"; [ -d \"$d\" ] || exit 0; find \"$d\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (this.text || "").split("\n")
                var list = []
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim()
                    if (p.length === 0) continue
                    var name = p.substring(p.lastIndexOf("/") + 1)
                    list.push({ name: name, path: p })
                }
                root.available = list
            }
        }
    }

    function _restoreForWorkspace(ws) {
        var key = String(ws)
        var path = root.mapping[key] || root.mapping["all"] || ""
        if (path.length > 0) _apply(path)
    }

    function _apply(path) {
        _img.command = ["awww", "img", "--transition-type", "none", path]
        _img.running = true
    }

    function _persist() {
        _write.command = ["sh", "-c", "cat > \"$HOME/.config/ember/wallpapers.json\""]
        _write.stdinEnabled = true
        _write.running = true
        _write.write(JSON.stringify(root.mapping, null, 2) + "\n")
        _write.closeStdin()
    }

    Component.onCompleted: _home.running = true
}
