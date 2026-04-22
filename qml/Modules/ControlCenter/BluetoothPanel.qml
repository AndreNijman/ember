import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 380

    Component.onCompleted: BluetoothService.startScan()
    Component.onDestruction: BluetoothService.stopScan()

    Column {
        id: col
        width: parent.width
        spacing: 0

        Rectangle {
            width: parent.width; height: Theme.rowH; color: Theme.ink2
            antialiasing: false
            Text {
                anchors.left: parent.left; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.discovering ? "BLUETOOTH · scanning" : "BLUETOOTH"
                color: Theme.ink6
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
                font.letterSpacing: 0.08 * Theme.t2xs
            }
        }

        Repeater {
            model: BluetoothService.devices
            delegate: Rectangle {
                required property var modelData
                width: col.width
                height: Theme.rowH
                color: modelData.connected ? Theme.ink2 : Theme.ink1
                antialiasing: false

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.s3
                    anchors.rightMargin: Theme.s3
                    spacing: Theme.s2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.connected ? "·" : ""
                        color: Theme.accent
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                        width: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name || modelData.address || "unknown"
                        color: modelData.connected ? Theme.ink8 : Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        elide: Text.ElideRight
                        width: parent.width - 60
                    }
                    Text {
                        visible: modelData.battery !== undefined && modelData.battery >= 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: (modelData.battery || 0) + "%"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                        font.features: {"tnum": 1}
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width
                    height: Theme.hairW; color: Theme.hairDim
                    antialiasing: false
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.connected)
                            BluetoothService.disconnectDevice(modelData)
                        else
                            BluetoothService.connectDevice(modelData)
                    }
                }
            }
        }

        Rectangle {
            visible: BluetoothService.devices.length === 0
            width: parent.width; height: Theme.rowH
            color: Theme.ink1
            Text {
                anchors.centerIn: parent
                text: BluetoothService.discovering ? "scanning..." : "no devices"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
            }
        }
    }
}
