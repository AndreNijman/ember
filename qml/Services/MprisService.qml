pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players ? Mpris.players.values : []
    readonly property var active: {
        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) return players[i]
        }
        return players.length > 0 ? players[0] : null
    }
    readonly property bool hasPlayer: active !== null

    readonly property string title: active && active.trackTitle ? active.trackTitle : ""
    readonly property string artist: active && active.trackArtist ? active.trackArtist : ""
    readonly property string album: active && active.trackAlbum ? active.trackAlbum : ""
    readonly property string artUrl: active && active.trackArtUrl ? active.trackArtUrl : ""
    readonly property bool playing: active ? active.playbackState === MprisPlaybackState.Playing : false
    readonly property real position: active ? active.position : 0
    readonly property real length_: active ? active.length : 0

    function playPause() { if (active) active.playPause() }
    function next()      { if (active) active.next() }
    function previous()  { if (active) active.previous() }
    function seek(pos)   { if (active) active.position = pos }
}
