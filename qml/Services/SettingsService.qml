pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Persisted settings — backed by ~/.config/aqs/settings.json. Defaults
    // mirror the historical hardcoded values so that an empty file leaves
    // behavior unchanged.
    property int  dpmsTimeoutSec: 180
    property int  lockTimeoutSec: 300
    property bool dndDefault:     false
    property bool barShowCpu:     true
    property bool barShowRam:     true
    property bool barShowNet:     true
    property bool barShowVpn:     true
    property string singBoxLabel: ""

    property string _path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/aqs/settings.json"
    property bool _loaded: false

    signal changed()

    property FileView _file: FileView {
        path: root._path
        blockLoading: false
        onLoaded: {
            try {
                var s = JSON.parse(this.text())
                if (s.dpmsTimeoutSec !== undefined) root.dpmsTimeoutSec = s.dpmsTimeoutSec
                if (s.lockTimeoutSec !== undefined) root.lockTimeoutSec = s.lockTimeoutSec
                if (s.dndDefault     !== undefined) root.dndDefault     = s.dndDefault
                if (s.barShowCpu     !== undefined) root.barShowCpu     = s.barShowCpu
                if (s.barShowRam     !== undefined) root.barShowRam     = s.barShowRam
                if (s.barShowNet     !== undefined) root.barShowNet     = s.barShowNet
                if (s.barShowVpn     !== undefined) root.barShowVpn     = s.barShowVpn
                if (s.singBoxLabel   !== undefined) root.singBoxLabel   = s.singBoxLabel
            } catch (e) {
                console.warn("SettingsService: parse failed:", e)
            }
            root._loaded = true
            root.changed()
        }
        onLoadFailed: {
            root._loaded = true
            root.save()
        }
    }

    function _snapshot() {
        return JSON.stringify({
            dpmsTimeoutSec: root.dpmsTimeoutSec,
            lockTimeoutSec: root.lockTimeoutSec,
            dndDefault:     root.dndDefault,
            barShowCpu:     root.barShowCpu,
            barShowRam:     root.barShowRam,
            barShowNet:     root.barShowNet,
            barShowVpn:     root.barShowVpn,
            singBoxLabel:   root.singBoxLabel,
        }, null, 2)
    }

    property Process _writer: Process {}

    function save() {
        if (!_loaded) return
        var body = _snapshot()
        _writer.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname \"$AQS_PATH\")\" && printf '%s' \"$AQS_BODY\" > \"$AQS_PATH\""
        ]
        _writer.environment = ({
            "AQS_PATH": root._path,
            "AQS_BODY": body,
        })
        _writer.running = true
        root.changed()
    }

    function set(key, value) {
        switch (key) {
            case "dpmsTimeoutSec": root.dpmsTimeoutSec = Number(value); break
            case "lockTimeoutSec": root.lockTimeoutSec = Number(value); break
            case "dndDefault":     root.dndDefault     = (value === true || value === "true"); break
            case "barShowCpu":     root.barShowCpu     = (value === true || value === "true"); break
            case "barShowRam":     root.barShowRam     = (value === true || value === "true"); break
            case "barShowNet":     root.barShowNet     = (value === true || value === "true"); break
            case "barShowVpn":     root.barShowVpn     = (value === true || value === "true"); break
            case "singBoxLabel":   root.singBoxLabel   = String(value); break
            default: return
        }
        save()
    }
}
