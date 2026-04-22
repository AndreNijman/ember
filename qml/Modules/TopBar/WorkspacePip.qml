import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Item {
    id: root
    //  WorkspacePip: a numbered box that flashes the accent strip when
    //  focused and dims when empty. Click to focus the workspace.
    property int wsId: 1
    property bool focused: false
    property bool occupied: false
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
        color: root.focused ? Theme.accent : (root.occupied ? Theme.ink8 : Theme.ink5)
        font.family: Theme.fontUi
        font.pixelSize: Theme.tsm
    }
    Atoms.Strip {
        anchors.bottom: parent.bottom
        active: root.focused
    }
    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
