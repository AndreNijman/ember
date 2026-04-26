import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 380

    Component.onCompleted: BluetoothService.startScan()
    Component.onDestruction: BluetoothService.stopScan()

    function _sortDevices(list) {
        var paired = [], avail = []
        for (var i = 0; i < list.length; i++) {
            if (list[i].paired) paired.push(list[i])
            else if (list[i].name && list[i].name.length > 0) avail.push(list[i])
        }
        avail.sort(function(a, b) { return (a.name || "").localeCompare(b.name || "") })
        return paired.concat(avail)
    }

    property var sortedDevices: _sortDevices(BluetoothService.devices)

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
            Text {
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.discovering ? "stop" : "scan"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (BluetoothService.discovering) BluetoothService.stopScan()
                        else BluetoothService.startScan()
                    }
                }
            }
        }

        Repeater {
            model: root.sortedDevices
            delegate: Rectangle {
                required property var modelData
                width: col.width
                height: Theme.rowH
                color: modelData.connected ? Theme.ink2 : Theme.ink1
                antialiasing: false

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.s3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.s2
                    width: parent.width - actionRow.width - Theme.s3 * 2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.connected ? "·" : (modelData.paired ? "‧" : "")
                        color: modelData.connected ? Theme.accent : Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                        width: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name || modelData.address || "unknown"
                        color: modelData.connected ? Theme.ink8 : (modelData.paired ? Theme.ink7 : Theme.ink6)
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        elide: Text.ElideRight
                        width: parent.width - 60
                    }
                    Text {
                        visible: modelData.battery !== undefined && modelData.battery > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: (modelData.battery || 0) + "%"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                        font.features: {"tnum": 1}
                    }
                    Text {
                        visible: modelData.pairing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "pairing…"
                        color: Theme.warn
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                    }
                }

                Row {
                    id: actionRow
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.s3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.s3

                    Text {
                        visible: modelData.paired
                        text: modelData.connected ? "disconnect" : "connect"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -Theme.s1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.connected) BluetoothService.disconnectDevice(modelData)
                                else BluetoothService.connectDevice(modelData)
                            }
                        }
                    }
                    Text {
                        visible: !modelData.paired && !modelData.pairing
                        text: "pair"
                        color: Theme.accent
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -Theme.s1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BluetoothService.pairDevice(modelData)
                        }
                    }
                    Text {
                        visible: modelData.paired
                        text: "forget"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -Theme.s1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BluetoothService.forgetDevice(modelData)
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width
                    height: Theme.hairW; color: Theme.hairDim
                    antialiasing: false
                }
            }
        }

        Rectangle {
            visible: root.sortedDevices.length === 0
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
