pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    //  Ipc singleton: owns the newline-delimited JSON Unix-socket server
    //  at $XDG_RUNTIME_DIR/aqs.sock. Uses Quickshell.IpcHandler — each
    //  `target` maps to a handler, and client `aqs ipc <target> <action>`
    //  is dispatched to the matching handler function.
    //
    //  Wire envelope (spec 04 §5):
    //    request:  { version, target, action, args? }
    //    response: { ok, value? | error? }
    //  The Quickshell IpcHandler API uses target + function names; the
    //  Go CLI packs args as a JSON array under `args`.

    property IpcHandler shell: IpcHandler {
        target: "shell"
        function version() { return JSON.stringify({ major: 0, minor: 1, patch: 0 }) }
        function status()  {
            return JSON.stringify({
                version:   { major: 0, minor: 1, patch: 0 },
                pid:       Quickshell.processId ? Quickshell.processId : 0,
                socket:    "$XDG_RUNTIME_DIR/aqs.sock",
                backend:   "qml"
            })
        }
        function restart() { Quickshell.reload(true); return "ok" }
        function keybinds() { return "see docs/keybinds.md" }
    }
    property IpcHandler bar: IpcHandler {
        target: "bar"
        function show()    { return "ok" }
        function hide()    { return "ok" }
        function toggle()  { return "ok" }
        function restart() { return "ok" }
    }
    property IpcHandler launcher: IpcHandler {
        target: "launcher"
        function toggle() { return "ok" }
        function show()   { return "ok" }
        function hide()   { return "ok" }
    }
    property IpcHandler notifications: IpcHandler {
        target: "notifications"
        function toggle()   { return "ok" }
        function clearAll() { return "ok" }
        function setDnd(v)  { return "ok" }
    }
    property IpcHandler control: IpcHandler {
        target: "control"
        function toggle() { return "ok" }
        function show()   { return "ok" }
        function hide()   { return "ok" }
    }
    property IpcHandler lock: IpcHandler {
        target: "lock"
        function engage() { return "ok" }
    }
    property IpcHandler osd: IpcHandler {
        target: "osd"
        function volume(v)     { return "ok" }
        function brightness(v) { return "ok" }
    }
    property IpcHandler wallpaper: IpcHandler {
        target: "wallpaper"
        function set(output, path) { return "ok" }
    }
    property IpcHandler workspace: IpcHandler {
        target: "workspace"
        function focus(id) { return "ok" }
    }
}
