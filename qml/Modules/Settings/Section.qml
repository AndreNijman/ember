import QtQuick
import "../../Theme"

Rectangle {
    property string title: ""
    width: parent ? parent.width : 0
    height: Theme.rowH
    color: Theme.ink2
    antialiasing: false

    Text {
        anchors.left: parent.left; anchors.leftMargin: Theme.s3
        anchors.verticalCenter: parent.verticalCenter
        text: parent.title
        color: Theme.ink6
        font.family: Theme.fontUi
        font.pixelSize: Theme.t2xs
        font.letterSpacing: 0.08 * Theme.t2xs
    }
}
