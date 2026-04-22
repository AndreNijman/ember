import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Theme"
import "../../Services"

PanelWindow {
    id: root
    property string kind: ""
    property real value: 0.0
    property bool muted: false
    property int timeoutMs: 1200

    visible: kind.length > 0
    implicitWidth: 320
    implicitHeight: 56
    color: Theme.ink1
    WlrLayershell.namespace: "aqs-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { bottom: true }
    margins { bottom: 80 }
    exclusiveZone: 0

    OsdBar {
        id: bar
        anchors.fill: parent
        anchors.margins: Theme.s3
        label: {
            if (root.kind === "volume") return "vol"
            if (root.kind === "brightness") return "bri"
            if (root.kind === "mic") return "mic"
            return root.kind
        }
        value: root.value
        muted: root.muted
    }

    Timer {
        id: dismiss
        interval: root.timeoutMs
        onTriggered: root.kind = ""
    }

    function _show(k, v, m) {
        kind = k; value = v; muted = m
        dismiss.restart()
    }
    function showVolume(v, m)   { _show("volume", v, m) }
    function showBrightness(v)  { _show("brightness", v, false) }
    function showMic(m)         { _show("mic", m ? 0 : 1, m) }
}
