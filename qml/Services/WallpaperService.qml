pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    //  WallpaperService manages one mpvpaper process per output. The
    //  WallpaperManager surface edits `entries` (output -> path); this
    //  service owns the spawn lifecycle. Stop is best-effort pkill.
    property var entries: ({})  // { "DP-1": "/path/to/file.mp4", ... }

    function set(output, path) {
        var e = Object.assign({}, root.entries)
        e[output] = path
        root.entries = e
        _spawn(output, path)
    }
    function clear(output) {
        var e = Object.assign({}, root.entries)
        delete e[output]
        root.entries = e
        _kill.command = ["pkill", "-f", "mpvpaper.*" + output]
        _kill.running = true
    }

    property Process _spawn_: Process { command: ["true"] }
    property Process _kill:   Process { command: ["true"] }

    function _spawn(output, path) {
        _kill.command = ["pkill", "-f", "mpvpaper.*" + output]
        _kill.running = true
        _spawn_.command = ["mpvpaper", "-o", "no-audio loop", output, path]
        _spawn_.running = true
    }
}
