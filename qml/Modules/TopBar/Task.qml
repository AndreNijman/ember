import QtQuick
import "../../Theme"

Item {
    id: root
    //  Task: a taskbar entry title. No icon per taskbar decision — title
    //  only, 2px accent strip underneath when active.
    property string title: ""
    property bool active: false
    signal clicked()

    implicitHeight: Theme.barH
    implicitWidth: label.implicitWidth + Theme.s3 * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: root.title
        color: root.active ? Theme.accent : Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
    Rectangle {
        visible: root.active
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: Theme.accent
        antialiasing: false
    }
    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
