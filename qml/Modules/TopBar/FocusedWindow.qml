import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    //  FocusedWindow shows the active window title in the centre of the bar.
    //  Elides to "…" when narrower than content. No icon.
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s4 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: HyprlandService.focusedWindowTitle || ""
        elide: Text.ElideRight
        maximumLineCount: 1
        width: root.width - Theme.s4 * 2
        horizontalAlignment: Text.AlignHCenter
        color: Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
}
