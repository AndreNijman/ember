pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource

    property PwObjectTracker _sinkTracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    property PwObjectTracker _sourceTracker: PwObjectTracker {
        objects: root.source ? [root.source] : []
    }

    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0
    readonly property bool muted:  sink && sink.audio ? sink.audio.muted  : false
    readonly property string sinkName: sink ? (sink.description || sink.name || "") : ""

    readonly property real sourceVolume: source && source.audio ? source.audio.volume : 0.0
    readonly property bool sourceMuted:  source && source.audio ? source.audio.muted  : false
    readonly property string sourceName: source ? (source.description || source.name || "") : ""

    property var sinks: []
    property var sources: []
    property var streams: []

    signal volumeSet(real value)

    function _rebuildLists() {
        var s = [], src = [], str = []
        for (var i = 0; i < Pipewire.nodes.length; i++) {
            var n = Pipewire.nodes[i]
            if (!n || !n.audio) continue
            if (n.isStream) { str.push(n); continue }
            if (n.isSink) s.push(n)
            else src.push(n)
        }
        sinks = s
        sources = src
        streams = str
    }

    onSinkChanged: _rebuildLists()
    onSourceChanged: _rebuildLists()
    Component.onCompleted: _rebuildLists()

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
    function toggleMicMute() {
        if (!source || !source.audio) return
        source.audio.muted = !source.audio.muted
    }
    function increment(pct) { setVolume(volume + pct / 100.0) }
    function decrement(pct) { setVolume(volume - pct / 100.0) }

    function setNodeVolume(node, v) {
        if (!node || !node.audio) return
        node.audio.volume = Math.max(0, Math.min(1.5, v))
    }
    function setNodeMuted(node, m) {
        if (!node || !node.audio) return
        node.audio.muted = m
    }
    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node
    }
    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node
    }
}
