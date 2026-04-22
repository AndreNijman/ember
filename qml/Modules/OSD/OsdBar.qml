import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms

Item {
    id: root
    //  OsdBar: a labeled horizontal progress used by the OSD surface.
    property string label: ""
    property real value: 0.0
    property bool muted: false

    implicitHeight: Theme.rowH * 2
    implicitWidth: 280

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s3
        spacing: Theme.s1
        Text {
            text: root.muted ? (root.label + " · mute") : root.label
            color: root.muted ? Theme.ink5 : Theme.ink7
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
        }
        Atoms.Bar {
            width: parent.width
            value: root.muted ? 0 : root.value
        }
    }
}
