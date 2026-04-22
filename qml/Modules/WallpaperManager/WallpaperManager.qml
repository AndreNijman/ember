import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

Window {
    id: root
    //  WallpaperManager: standalone 1024x640 window. Output list on the
    //  left, preview tiles on the right. The full browser logic is out of
    //  scope for this initial implementation; the window hosts a stub grid
    //  so the keybind and IPC targets round-trip.
    property bool open_: false
    visible: open_
    width: 1024
    height: 640
    color: Theme.ink1
    title: "aqs wallpaper"

    Row {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            width: 200
            height: parent.height
            color: Theme.ink2
            antialiasing: false
            Column {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: Theme.s2
                Text {
                    text: "outputs"
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    font.capitalization: Font.AllUppercase
                }
            }
        }
        Rectangle {
            width: parent.width - 200
            height: parent.height
            color: Theme.ink1
            antialiasing: false
            Grid {
                anchors.fill: parent
                anchors.margins: Theme.s3
                columns: 4
                rowSpacing: Theme.s3
                columnSpacing: Theme.s3
            }
        }
    }
}
