import QtQuick
import "../Theme"

Rectangle {
    id: root
    //  Pip is a tiny 4x4 square used for workspace presence indicators.
    //  Three states: inactive (ink5), occupied (ink7), focused (accent).
    property int state_: 0   // 0=empty,1=occupied,2=focused
    implicitWidth: 4
    implicitHeight: 4
    color: state_ === 2 ? Theme.accent : state_ === 1 ? Theme.ink7 : Theme.ink5
    radius: 0
    antialiasing: false
}
