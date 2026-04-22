import QtQuick
import Quickshell
import "../TopBar"
import "../Launcher"
import "../NotificationCenter"
import "../ControlCenter"
import "../OSD"
import "../Lock"
import "../WallpaperManager"

QtObject {
    id: root
    //  ShellRoot: instantiates one TopBar per output plus the singleton
    //  popup surfaces. The popups stay hidden until the IPC toggles them.
    //  All services are singletons and auto-initialise when imported.

    property var bars: Variants {
        model: Quickshell.screens
        delegate: TopBar {
            required property var modelData
            screen: modelData
        }
    }

    property Launcher          launcher:     Launcher {}
    property NotificationCenter notifCentre: NotificationCenter {}
    property ControlCenter      control:     ControlCenter {}
    property OsdHost            osd:         OsdHost {}
    property Lock               lock:        Lock {}
    property WallpaperManager   wallpaper:   WallpaperManager {}
}
