import QtQuick
import "../Theme"

Row {
    id: root
    //  Segments: segmented control. `items` is a list of strings,
    //  `index` is the active entry. No radius, hairlines between segments.
    property var items: []
    property int index: 0
    signal picked(int index)

    spacing: 0
    Repeater {
        model: root.items
        delegate: Rectangle {
            required property int index
            required property string modelData
            width: Math.max(Theme.tap, text.implicitWidth + Theme.s4 * 2)
            height: Theme.rowH
            color: index === root.index ? Theme.ink2 : Theme.ink1
            border.width: Theme.hairW
            border.color: index === root.index ? Theme.accent : Theme.hair
            antialiasing: false
            Text {
                id: text
                anchors.centerIn: parent
                text: modelData
                color: index === root.index ? Theme.accent : Theme.ink7
                font.family: Theme.fontUi
                font.pixelSize: Theme.tsm
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.index = index
                    root.picked(index)
                }
            }
        }
    }
}
