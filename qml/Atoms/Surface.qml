import QtQuick
import "../Theme"

Rectangle {
    id: root
    //  Surface is the background primitive. Level 0 is canvas ink0,
    //  level 1 is ink1, level 2 is ink2. Borders are hairlines.
    property int level: 1
    property bool bordered: false
    property bool borderAccent: false

    color: level === 0 ? Theme.ink0 : level === 2 ? Theme.ink2 : Theme.ink1
    radius: Theme.radius
    antialiasing: false
    border.width: bordered ? Theme.hairW : 0
    border.color: borderAccent ? Theme.accent : Theme.hair
}
