import QtQuick
import QtQuick.Controls
import "../Theme"

TextField {
    id: root
    //  Field: text input. Flat, hairline border, accent on focus. No radius.
    color: Theme.ink8
    selectionColor: Theme.accent
    selectedTextColor: Theme.accentFg
    placeholderTextColor: Theme.ink5
    font.family: Theme.fontUi
    font.pixelSize: Theme.tmd
    padding: Theme.s2
    background: Rectangle {
        color: Theme.ink1
        border.width: Theme.hairW
        border.color: root.activeFocus ? Theme.accent : Theme.hair
        radius: 0
        antialiasing: false
    }
}
