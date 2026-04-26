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
import "Modules/Keybinds"
import "Modules/Clipboard"
import "Modules/SingBox"
import "Modules/Calendar"
import "Modules/Overview"
import "Modules/Settings"
import "Modules/PowerMenu"
import "Modules/Colors"
import "Modules/WindowRules"
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
    ToastHost          { id: toasts  }
    ControlCenter      { id: control  }
    OsdHost            { id: osd      }
    Lock               { id: lock     }
    WallpaperManager   { id: wallpaper }
    Keybinds           { id: keybinds }
    Calendar           { id: calendar }
    Overview           { id: overview }
    Clipboard          { id: clipboard }
    SingBoxPanel       { id: singbox  }
    Settings           { id: settings }
    PowerMenu          { id: powermenu }
    Colors             { id: colors }
    WindowRules        { id: windowrules }

    Connections {
        target: HyprlandService
        function onFocusedWorkspaceIdChanged() {
            WallpaperService.onWorkspaceChanged(HyprlandService.focusedWorkspaceId)
        }
    }

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
        function onToggleSingBox()        { singbox.open_ = !singbox.open_ }
        function onShowSingBox()          { singbox.open_ = true }
        function onHideSingBox()          { singbox.open_ = false }
        function onToggleClipboard()      { clipboard.open_ = !clipboard.open_ }
        function onShowClipboard()        { clipboard.open_ = true }
        function onHideClipboard()        { clipboard.open_ = false }
        function onToggleCalendar()       { calendar.open_ = !calendar.open_ }
        function onShowCalendar()         { calendar.open_ = true }
        function onHideCalendar()         { calendar.open_ = false }
        function onToggleOverview()      { overview.open_ = !overview.open_ }
        function onShowOverview()        { overview.open_ = true }
        function onHideOverview()        { overview.open_ = false }
        function onToggleKeybinds()      { keybinds.open_ = !keybinds.open_ }
        function onShowKeybinds()        { keybinds.open_ = true }
        function onHideKeybinds()        { keybinds.open_ = false }
        function onToggleWallpaper()     { wallpaper.open_ = !wallpaper.open_ }
        function onShowWallpaper()       { wallpaper.open_ = true }
        function onHideWallpaper()       { wallpaper.open_ = false }
        function onToggleSettings()      { settings.open_ = !settings.open_ }
        function onShowSettings()        { settings.open_ = true }
        function onHideSettings()        { settings.open_ = false }
        function onTogglePowerMenu()     { powermenu.open_ = !powermenu.open_ }
        function onShowPowerMenu()       { powermenu.open_ = true }
        function onHidePowerMenu()       { powermenu.open_ = false }
        function onToggleColors()        { colors.open_ = !colors.open_ }
        function onShowColors()          { colors.open_ = true }
        function onHideColors()          { colors.open_ = false }
        function onPickColor()           { ColorService.pick() }
        function onToggleWindowRules()   { windowrules.open_ = !windowrules.open_ }
        function onShowWindowRules()     { windowrules.open_ = true }
        function onHideWindowRules()     { windowrules.open_ = false }
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
        function toggle(): string { Ipc.toggleWallpaper(); return "ok" }
        function show(): string   { Ipc.showWallpaper();   return "ok" }
        function hide(): string   { Ipc.hideWallpaper();   return "ok" }
        function setForWorkspace(ws: string, path: string): string {
            WallpaperService.setForWorkspace(Number(ws), path); return "ok"
        }
        function setAll(path: string): string {
            WallpaperService.setAll(path); return "ok"
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
        function micmute(): string {
            AudioService.toggleMicMute()
            osd.showMic(AudioService.sourceMuted)
            return "ok"
        }
    }
    IpcHandler {
        target: "keybinds"
        function toggle(): string { Ipc.toggleKeybinds(); return "ok" }
        function show(): string   { Ipc.showKeybinds();   return "ok" }
        function hide(): string   { Ipc.hideKeybinds();   return "ok" }
    }
    IpcHandler {
        target: "singbox"
        function toggle(): string { Ipc.toggleSingBox(); return "ok" }
        function show(): string   { Ipc.showSingBox();   return "ok" }
        function hide(): string   { Ipc.hideSingBox();   return "ok" }
        function connect(): string { SingBoxService.toggle(); return "ok" }
    }
    IpcHandler {
        target: "clipboard"
        function toggle(): string { Ipc.toggleClipboard(); return "ok" }
        function show(): string   { Ipc.showClipboard();   return "ok" }
        function hide(): string   { Ipc.hideClipboard();   return "ok" }
    }
    IpcHandler {
        target: "overview"
        function toggle(): string { Ipc.toggleOverview(); return "ok" }
        function show(): string   { Ipc.showOverview();   return "ok" }
        function hide(): string   { Ipc.hideOverview();   return "ok" }
    }
    IpcHandler {
        target: "windowrules"
        function toggle(): string { Ipc.toggleWindowRules(); return "ok" }
        function show(): string   { Ipc.showWindowRules();   return "ok" }
        function hide(): string   { Ipc.hideWindowRules();   return "ok" }
    }
    IpcHandler {
        target: "colors"
        function toggle(): string { Ipc.toggleColors(); return "ok" }
        function show(): string   { Ipc.showColors();   return "ok" }
        function hide(): string   { Ipc.hideColors();   return "ok" }
        function pick(): string   { Ipc.pickColor();    return "ok" }
    }
    IpcHandler {
        target: "powermenu"
        function toggle(): string { Ipc.togglePowerMenu(); return "ok" }
        function show(): string   { Ipc.showPowerMenu();   return "ok" }
        function hide(): string   { Ipc.hidePowerMenu();   return "ok" }
    }
    IpcHandler {
        target: "settings"
        function toggle(): string { Ipc.toggleSettings(); return "ok" }
        function show(): string   { Ipc.showSettings();   return "ok" }
        function hide(): string   { Ipc.hideSettings();   return "ok" }
        function open(): string   { Ipc.showSettings();   return "ok" }
        function set(key: string, value: string): string {
            SettingsService.set(key, value); return "ok"
        }
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
