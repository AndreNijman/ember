import QtQuick
import "../../Theme"
import "../../Services"

Rectangle {
    id: root
    //  CalcStrip: visible when the launcher query starts with "=" — shows
    //  the qalc result in the accent color on a single row.
    property string query: ""
    visible: query.startsWith("=")
    implicitHeight: visible ? Theme.rowH : 0
    color: Theme.ink2
    antialiasing: false

    onQueryChanged: CalcService.query = query.startsWith("=") ? query.substring(1).trim() : ""

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.s3
        anchors.rightMargin: Theme.s3
        spacing: Theme.s3
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "="
            color: Theme.accent
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: CalcService.result
            color: Theme.ink8
            font.family: Theme.fontUi
            font.pixelSize: Theme.tmd
        }
    }
}
