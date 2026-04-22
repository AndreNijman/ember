import QtQuick
import "../../Theme"
import "../../Services"

Item {
    id: root
    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 380

    Component.onCompleted: NetworkService.scanWifi()

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
                text: NetworkService.scanning ? "WIFI · scanning" : "WIFI · " + NetworkService.wifiList.length + " networks"
                color: Theme.ink6
                font.family: Theme.fontUi
                font.pixelSize: Theme.t2xs
                font.letterSpacing: 0.08 * Theme.t2xs
            }
            Text {
                anchors.right: parent.right; anchors.rightMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                text: "rescan"
                color: Theme.ink5
                font.family: Theme.fontUi
                font.pixelSize: Theme.txs
                MouseArea {
                    anchors.fill: parent; anchors.margins: -Theme.s1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NetworkService.scanWifi()
                }
            }
        }

        Repeater {
            model: NetworkService.wifiList
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: col.width
                height: Theme.rowH
                color: modelData.active ? Theme.ink2 : Theme.ink1
                antialiasing: false

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.s3
                    anchors.rightMargin: Theme.s3
                    spacing: Theme.s2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.active ? "·" : ""
                        color: Theme.accent
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.tsm
                        width: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.ssid
                        color: modelData.active ? Theme.ink8 : Theme.ink7
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                        elide: Text.ElideRight
                        width: parent.width - 80
                    }
                    Text {
                        visible: modelData.security.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⊡"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.txs
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.signal + "%"
                        color: Theme.ink5
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.t2xs
                        font.features: {"tnum": 1}
                        horizontalAlignment: Text.AlignRight
                        width: 28
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
                        if (!modelData.active)
                            NetworkService.connectWifi(modelData.ssid, "")
                    }
                }
            }
        }
    }
}
