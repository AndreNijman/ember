pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root
    //  AudioService wraps Quickshell.Pipewire. Exposes the default sink's
    //  volume + mute state plus a setter. The shell's Volume composite
    //  and OSD read from here. Dbus only — no wpctl shelling.
    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource

    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0
    readonly property bool muted:  sink && sink.audio ? sink.audio.muted  : false
    readonly property string sinkName: sink ? (sink.description || sink.name || "") : ""

    signal volumeSet(real value)

    function setVolume(v) {
        if (!sink || !sink.audio) return
        var clamped = Math.max(0, Math.min(1.5, v))
        sink.audio.volume = clamped
        root.volumeSet(clamped)
    }
    function toggleMute() {
        if (!sink || !sink.audio) return
        sink.audio.muted = !sink.audio.muted
    }
}
