import QtQuick
import "../../Theme"

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    default property alias inputItem: inputSlot.children

    width: parent ? parent.width : 0
    height: Theme.rowH
    color: Theme.ink1
    antialiasing: false

    // Allow `input: <component>` declarative property
    property Item input: null
    onInputChanged: if (input) input.parent = inputSlot

    Text {
        anchors.left: parent.left; anchors.leftMargin: Theme.s3
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.ink7
        font.family: Theme.fontUi
        font.pixelSize: Theme.txs
    }

    Item {
        id: inputSlot
        anchors.right: parent.right; anchors.rightMargin: Theme.s3
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }

    Rectangle {
        anchors.bottom: parent.bottom; width: parent.width
        height: Theme.hairW; color: Theme.hairDim
        antialiasing: false
    }
}
