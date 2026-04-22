import QtQuick
import "../../Theme"

Rectangle {
    id: root
    //  ToggleTile: a boxed on/off tile. 1px hairline border, accent when on.
    property string label: ""
    property bool on: false
    signal toggled(bool value)

    implicitHeight: Theme.tap
    implicitWidth: 160
    color: on ? Theme.ink2 : Theme.ink1
    border.width: Theme.hairW
    border.color: on ? Theme.accent : Theme.hair
    antialiasing: false

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s3
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.on ? Theme.accent : Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.tsm
        }
        Item { width: 1; height: 1 }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: { root.on = !root.on; root.toggled(root.on) }
    }
}
