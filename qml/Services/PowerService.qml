pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root
    //  PowerService wraps UPower. Exposes only what the top-bar Battery
    //  composite and ControlCenter.Power panel need.
    readonly property bool onBattery: UPower.onBattery
    readonly property var   device:    UPower.displayDevice
    readonly property real  percent:   device ? device.percentage : 0.0
    readonly property int   state_:    device ? device.state : 0
    readonly property real  timeSec:   device ? (onBattery ? device.timeToEmpty : device.timeToFull) : 0
    readonly property string iconName: device ? device.iconName : ""
    readonly property bool  charging:  device ? device.state === UPowerDeviceState.Charging : false
    readonly property bool  full:      device ? device.state === UPowerDeviceState.FullyCharged : false
}
