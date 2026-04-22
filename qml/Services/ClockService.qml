pragma Singleton
import QtQuick

QtObject {
    id: root
    //  ClockService: current wall time + date string. Tick at 1s cadence.
    property date now: new Date()
    property string timeText: Qt.formatDateTime(now, "HH:mm")
    property string timeTextSec: Qt.formatDateTime(now, "HH:mm:ss")
    property string dateText: Qt.formatDate(now, "ddd d MMM")

    property Timer _tick: Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }
}
