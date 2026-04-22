import QtQuick
import "../../Theme"

Rectangle {
    id: root
    //  Tile: wallpaper preview entry. Title + path. Selected highlights
    //  with an accent border.
    property string title: ""
    property string path: ""
    property bool selected: false
    signal picked()

    implicitWidth: 180
    implicitHeight: 120
    color: Theme.ink2
    border.width: Theme.hairW
    border.color: selected ? Theme.accent : Theme.hair
    antialiasing: false

    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: Theme.s2
        text: root.title
        color: Theme.ink8
        font.family: Theme.fontUi
        font.pixelSize: Theme.txs
    }
    MouseArea { anchors.fill: parent; onClicked: root.picked() }
}
