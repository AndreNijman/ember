import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    //  Lock surface: fills the screen, layer overlay. Large serif clock
    //  centered, auth field under it. Visible only when LockService.locked.
    visible: LockService.locked
    anchors { top: true; bottom: true; left: true; right: true }
    color: Theme.ink0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aqs-lock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Column {
        anchors.centerIn: parent
        spacing: Theme.s6
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(ClockService.now, "HH:mm")
            color: Theme.ink8
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.lock.clockSize
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(ClockService.now, "dddd d MMMM yyyy")
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
        }
        AuthField {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
        }
    }
}
