import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    visible: MprisService.hasPlayer && MprisService.title.length > 0
    implicitHeight: Theme.barH
    implicitWidth: row.implicitWidth + Theme.s3 * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s2

        Item {
            id: artFrame
            width: 16; height: 16
            visible: MprisService.artUrl.length > 0
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.fill: parent
                anchors.margins: Theme.hairW
                source: MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                smooth: false
                antialiasing: false
                sourceSize: Qt.size(32, 32)
            }
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: Theme.hairW
                border.color: Theme.hair
                antialiasing: false
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
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
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: MprisService.playPause()
    }
}
