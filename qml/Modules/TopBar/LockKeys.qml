import QtQuick
import "../../Theme"
import "../../Services"

// LockKeys: shows CAPS / NUM / SCRL letters only when their LED is lit.
// Hides entirely when none are active.
Item {
    id: root
    visible: LockKeysService.capsLock || LockKeysService.numLock || LockKeysService.scrollLock
    implicitHeight: Theme.barH
    implicitWidth: visible ? row.implicitWidth + Theme.s2 * 2 : 0

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.s2

        Text {
            visible: LockKeysService.capsLock
            text: "CAPS"
            color: Theme.warn
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
            font.letterSpacing: 0.08 * Theme.t2xs
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: LockKeysService.numLock
            text: "NUM"
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
            font.letterSpacing: 0.08 * Theme.t2xs
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: LockKeysService.scrollLock
            text: "SCRL"
            color: Theme.ink6
            font.family: Theme.fontUi
            font.pixelSize: Theme.t2xs
            font.letterSpacing: 0.08 * Theme.t2xs
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
