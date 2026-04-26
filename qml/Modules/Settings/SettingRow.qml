import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    default property alias inputItem: inputSlot.children

    width: parent ? parent.width : 0
    height: Theme.rowH
    color: hover.hovered ? Theme.ink2 : Theme.ink1
    antialiasing: false
    Behavior on color { ColorAnimation { duration: Theme.tFast } }

    // Allow `input: <component>` declarative property
    property Item input: null
    onInputChanged: if (input) input.parent = inputSlot

    Atoms.Hover {
        id: hover
        anchors.fill: parent
        cursorShape: root.input && root.input.activeFocusOnTab ? Qt.IBeamCursor : Qt.PointingHandCursor
        onClicked: {
            if (root.input && root.input.forceActiveFocus)
                root.input.forceActiveFocus()
            else if (root.input && root.input.toggled)
                root.input.toggled(!root.input.on)
        }
    }

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
