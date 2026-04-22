import QtQuick
import Quickshell
import Quickshell.Io
import "Modules/TopBar"
import "Modules/Launcher"
import "Modules/NotificationCenter"
import "Modules/ControlCenter"
import "Modules/OSD"
import "Modules/Lock"
import "Modules/WallpaperManager"
import "Services"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
        TopBar {
            required property var modelData
            screen: modelData
        }
    }

    Launcher           { id: launcher }
    NotificationCenter { id: notif    }
    ControlCenter      { id: control  }
    OsdHost            { id: osd      }
    Lock               { id: lock     }
    WallpaperManager   { id: wallpaper }

    Connections {
        target: Ipc
        function onToggleLauncher()      { launcher.open_ = !launcher.open_ }
        function onShowLauncher()        { launcher.open_ = true }
        function onHideLauncher()        { launcher.open_ = false }
        function onToggleControl()       { control.open_  = !control.open_ }
        function onShowControl()         { control.open_  = true }
        function onHideControl()         { control.open_  = false }
        function onToggleNotifications() { notif.open_    = !notif.open_ }
        function onClearNotifications()  { NotifService.clearAll() }
        function onSetDnd(v)             { NotifService.dnd = v }
        function onLockEngage()          { LockService.lock() }
        function onOsdVolume(v)          { AudioService.setVolume(v); osd.showVolume(v, AudioService.muted) }
        function onOsdBrightness(v)      { BrightnessService.set(v); osd.showBrightness(v) }
        function onWorkspaceFocus(id)    { HyprlandService.focusWorkspace(id) }
        function onSetWallpaper(out, p)  { WallpaperService.set(out, p) }
    }

    IpcHandler {
        target: "shell"
        function status(): string   { return Ipc.status() }
        function version(): string  { return JSON.stringify({major:0,minor:1,patch:0}) }
        function restart(): string  { Quickshell.reload(true); return "ok" }
        function keybinds(): string { return "see docs/keybinds.md" }
    }
    IpcHandler {
        target: "launcher"
        function toggle(): string { Ipc.toggleLauncher(); return "ok" }
        function show(): string   { Ipc.showLauncher();   return "ok" }
        function hide(): string   { Ipc.hideLauncher();   return "ok" }
    }
    IpcHandler {
        target: "control"
        function toggle(): string { Ipc.toggleControl(); return "ok" }
        function show(): string   { Ipc.showControl();   return "ok" }
        function hide(): string   { Ipc.hideControl();   return "ok" }
    }
    IpcHandler {
        target: "notifications"
        function toggle(): string   { Ipc.toggleNotifications(); return "ok" }
        function clearAll(): string { Ipc.clearNotifications();  return "ok" }
        function setDnd(v: string): string { Ipc.setDnd(v === "true"); return "ok" }
    }
    IpcHandler {
        target: "lock"
        function engage(): string { Ipc.lockEngage(); return "ok" }
        function lock(): string   { Ipc.lockEngage(); return "ok" }
    }
    IpcHandler {
        target: "osd"
        function volume(v: string): string     { Ipc.osdVolume(Number(v));     return "ok" }
        function brightness(v: string): string { Ipc.osdBrightness(Number(v)); return "ok" }
    }
    IpcHandler {
        target: "workspace"
        function focus(id: string): string { Ipc.workspaceFocus(Number(id)); return "ok" }
    }
    IpcHandler {
        target: "wallpaper"
        function set(output: string, path: string): string {
            Ipc.setWallpaper(output, path); return "ok"
        }
    }
    IpcHandler {
        target: "audio"
        function increment(n: string): string {
            AudioService.increment(Number(n))
            osd.showVolume(AudioService.volume, AudioService.muted)
            return "ok"
        }
        function decrement(n: string): string {
            AudioService.decrement(Number(n))
            osd.showVolume(AudioService.volume, AudioService.muted)
            return "ok"
        }
        function mute(): string {
            AudioService.toggleMute()
            osd.showVolume(AudioService.volume, AudioService.muted)
            return "ok"
        }
        function micmute(): string { AudioService.toggleMicMute(); return "ok" }
    }
    IpcHandler {
        target: "brightness"
        function increment(n: string): string {
            BrightnessService.increment(Number(n))
            osd.showBrightness(BrightnessService.value)
            return "ok"
        }
        function decrement(n: string): string {
            BrightnessService.decrement(Number(n))
            osd.showBrightness(BrightnessService.value)
            return "ok"
        }
    }
}
