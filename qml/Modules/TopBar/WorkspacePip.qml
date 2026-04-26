import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Item {
    id: root
    property int wsId: 1
    property string wsName: ""
    property bool focused: false
    signal clicked()

    implicitWidth: Math.max(20, idText.implicitWidth + Theme.s2 * 2,
                            nameText.visible ? nameText.implicitWidth + Theme.s2 * 2 : 0)
    implicitHeight: Theme.barH

    Rectangle {
        anchors.fill: parent
        color: root.focused ? Theme.ink2 : "transparent"
        antialiasing: false
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
    }
    Column {
        anchors.centerIn: parent
        spacing: 0
        Text {
            id: idText
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.wsId
            color: root.focused ? Theme.accent : Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: nameText.visible ? Theme.t2xs : Theme.tsm
            font.features: {"tnum": 1}
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
        Text {
            id: nameText
            visible: root.wsName.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.wsName
            color: root.focused ? Theme.ink8 : Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
            font.letterSpacing: 0.04 * Theme.t2xs
        }
    }
    Atoms.Strip {
        anchors.bottom: parent.bottom
        active: root.focused
    }
    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
