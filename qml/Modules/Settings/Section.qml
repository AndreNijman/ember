import QtQuick
import "../../Theme"

Item {
    property string title: ""
    width: parent ? parent.width : 0
    height: Theme.s5 + Theme.rowH * 0.6

    Text {
        anchors.left: parent.left; anchors.leftMargin: Theme.s3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.s2
        text: parent.title
        color: Theme.ink5
        font.family: Theme.fontUi
        font.pixelSize: Theme.t2xs
        font.letterSpacing: 0.08 * Theme.t2xs
    }
}
