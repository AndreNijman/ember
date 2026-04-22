import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    visible: MprisService.hasPlayer
    implicitHeight: visible ? col.implicitHeight : 0
    implicitWidth: parent ? parent.width : 380

    Column {
        id: col
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "MEDIA"
                color: Theme.ink6
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
                font.letterSpacing: 0.08 * Theme.t2xs
            }
        }

        Item {
            width: parent.width
            height: Theme.rowH * 2
            Column {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: 2
                Text {
                    text: MprisService.title
                    color: Theme.ink8
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tsm
                    width: parent.width
                    elide: Text.ElideRight
                }
                Text {
                    text: MprisService.artist
                    color: Theme.ink6
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.txs
                    width: parent.width
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            width: parent.width
            height: Theme.rowH
            Atoms.Slider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Theme.s3
                anchors.rightMargin: Theme.s3
                value: MprisService.length_ > 0 ? MprisService.position / MprisService.length_ : 0
                onChanged: (v) => MprisService.seek(v * MprisService.length_)
            }
        }

        Item {
            width: parent.width
            height: Theme.tap
            Row {
                anchors.centerIn: parent
                spacing: Theme.s5

                Text {
                    text: "⏮"
                    color: Theme.ink7
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s2
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.previous()
                    }
                }
                Text {
                    text: MprisService.playing ? "⏸" : "▶"
                    color: Theme.accent
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tlg
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s2
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.playPause()
                    }
                }
                Text {
                    text: "⏭"
                    color: Theme.ink7
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.tmd
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -Theme.s2
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.next()
                    }
                }
            }
        }
    }
}
