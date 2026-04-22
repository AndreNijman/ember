import QtQuick
import "../../Theme"
import "../../Atoms" as Atoms
import "../../Services"

Item {
    id: root
    //  AuthField: password entry bound to LockService. Submits on Enter.
    implicitHeight: Theme.tap
    implicitWidth: 320

    Column {
        anchors.fill: parent
        spacing: Theme.s1
        Atoms.Field {
            id: input
            width: parent.width
            echoMode: TextInput.Password
            placeholderText: "password"
            enabled: !LockService.authenticating
            onAccepted: LockService.submit(text)
        }
        Text {
            visible: LockService.lastError.length > 0
            text: LockService.lastError
            color: Theme.err
            font.family: Theme.fontUi
            font.pixelSize: Theme.txs
        }
    }
}
