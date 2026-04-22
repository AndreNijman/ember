import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

PanelWindow {
    id: root
    //  Launcher: 640px wide centered 25% from top, opens on demand via
    //  `aqs ipc launcher toggle`. Flat ink1 canvas, hairline border,
    //  one field + result list + calc strip + footer.
    property bool open_: false
    visible: open_

    implicitWidth: 640
    implicitHeight: column.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true }
    margins { top: 200 }
    exclusiveZone: 0

    Column {
        id: column
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width
            height: Theme.hairW
            color: Theme.hair
            antialiasing: false
        }
        Atoms.Field {
            id: input
            width: parent.width
            placeholderText: "run, search, or =expr"
            focus: root.open_
            onTextChanged: AppService.query = text
            Keys.onEscapePressed: (event) => { root.open_ = false; event.accepted = true }
            Keys.onReturnPressed: (event) => {
                if (AppService.results.length > 0) {
                    AppService.launch(AppService.results[list.currentIndex].id)
                    root.open_ = false
                }
                event.accepted = true
            }
        }
        CalcStrip {
            width: parent.width
            query: input.text
        }
        ListView {
            id: list
            width: parent.width
            height: Math.min(320, contentHeight)
            clip: true
            model: AppService.results
            delegate: ResultRow {
                required property var modelData
                required property int index
                width: list.width
                title: modelData.name || ""
                subtitle: modelData.exec || ""
                selected: list.currentIndex === index
                onActivated: {
                    AppService.launch(modelData.id)
                    root.open_ = false
                }
            }
            keyNavigationWraps: true
        }
        Rectangle {
            width: parent.width
            height: Theme.rowH
            color: Theme.ink0
            antialiasing: false
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.s3
                text: "⏎ run   ↑↓ nav   ⎋ close"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
        Rectangle {
            width: parent.width
            height: Theme.hairW
            color: Theme.hair
            antialiasing: false
        }
    }

}
