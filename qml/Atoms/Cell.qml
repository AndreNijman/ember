import QtQuick
import "../Theme"

Item {
    id: root
    //  Cell is a fixed-height rectangular slot used by the bar segments
    //  and rows. It hosts one text string, optionally preceded by a glyph.
    property string label: ""
    property string leading: ""
    property bool active: false
    property color fg: Theme.ink8
    property int fontSize: Theme.tsm

    implicitHeight: Theme.barH
    implicitWidth: contentRow.implicitWidth + Theme.s3 * 2

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.s1
        Text {
            visible: root.leading.length > 0
            text: root.leading
            color: root.active ? Theme.accent : root.fg
            font.family: Theme.fontUi
            font.pixelSize: root.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.label
            color: root.active ? Theme.accent : root.fg
            font.family: Theme.fontUi
            font.pixelSize: root.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
