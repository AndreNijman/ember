import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: MprisService.hasPlayer && MprisService.title.length > 0
    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            var t = MprisService.title
            var a = MprisService.artist
            if (a.length > 0) return t + " · " + a
            return t
        }
        color: Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 280)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: MprisService.playPause()
    }
}
