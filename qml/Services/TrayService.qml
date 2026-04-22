pragma Singleton
import QtQuick
import Quickshell.Services.SystemTray

QtObject {
    id: root
    //  TrayService exposes the current StatusNotifierItem list, already
    //  modeled by Quickshell. Consumers (TopBar/TrayStrip) iterate `items`.
    readonly property var items: SystemTray.items ? SystemTray.items.values : []
}
