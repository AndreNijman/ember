import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PopupWindow {
    id: root
    //  OsdHost: 280px-wide popup centred-bottom. Shows one OsdBar at a time.
    property string kind: ""  // "volume" | "brightness" | "caps"
    property real value: 0.0
    property bool muted: false
    property int   timeoutMs: 1200

    visible: kind.length > 0
    implicitWidth: 280
    implicitHeight: bar.implicitHeight
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-osd"
    anchor.window: null

    OsdBar {
        id: bar
        anchors.fill: parent
        label: root.kind === "volume" ? "volume" :
               root.kind === "brightness" ? "brightness" :
               root.kind === "caps" ? "caps lock" : ""
        value: root.value
        muted: root.muted
    }

    Timer {
        interval: root.timeoutMs
        running: root.visible
        onTriggered: root.kind = ""
    }

    function showVolume(v, muted) { value = v; this.muted = muted; kind = "volume" }
    function showBrightness(v)    { value = v; muted = false;     kind = "brightness" }
    function showCaps(on)         { value = on ? 1 : 0; muted = false; kind = "caps" }
}
