import QtQuick
import "../Theme"

Text {
    id: root
    //  Glyph is a single-glyph label: an icon char or numeric state.
    //  Uses the UI mono stack by default. Kind == "display" switches to
    //  the serif stack (used by lock clock).
    property string kind: "ui"
    property color tint: Theme.ink8
    property bool accent: false

    color: accent ? Theme.accent : tint
    font.family: kind === "display" ? Theme.fontDisplay : Theme.fontUi
    font.pixelSize: Theme.tmd
    font.weight: Font.Normal
    renderType: Text.NativeRendering
    antialiasing: true
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
