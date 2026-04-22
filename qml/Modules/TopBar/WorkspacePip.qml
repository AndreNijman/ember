import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Item {
    id: root
    property int wsId: 1
    property bool focused: false
    signal clicked()

    implicitWidth: 20
    implicitHeight: Theme.barH

    Rectangle {
        anchors.fill: parent
        color: root.focused ? Theme.ink2 : "transparent"
        antialiasing: false
    }
    Text {
        anchors.centerIn: parent
        text: root.wsId
        color: root.focused ? Theme.accent : Theme.ink8
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
        font.features: {"tnum": 1}
    }
    Atoms.Strip {
        anchors.bottom: parent.bottom
        active: root.focused
    }
    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
