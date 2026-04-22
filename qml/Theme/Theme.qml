pragma Singleton
import QtQuick
import "."

QtObject {
    //  Theme is the single-source-of-truth facade. Every consumer imports
    //  Theme and reads Theme.ink0, Theme.accent, Theme.barH, etc.
    //  The underlying values live in Tokens.qml; no module outside Theme/
    //  is allowed to hold literal colors, sizes, or durations.

    readonly property color ink0: Tokens.ink0
    readonly property color ink1: Tokens.ink1
    readonly property color ink2: Tokens.ink2
    readonly property color ink3: Tokens.ink3
    readonly property color ink4: Tokens.ink4
    readonly property color ink5: Tokens.ink5
    readonly property color ink6: Tokens.ink6
    readonly property color ink7: Tokens.ink7
    readonly property color ink8: Tokens.ink8

    readonly property color hair:    Tokens.hair
    readonly property color hairDim: Tokens.hairDim
    readonly property int   hairW:   Tokens.hairW

    readonly property color accent:    Tokens.accent
    readonly property color accentDim: Tokens.accentDim
    readonly property color accentFg:  Tokens.accentFg

    readonly property color ok:   Tokens.ok
    readonly property color warn: Tokens.warn
    readonly property color err:  Tokens.err

    readonly property string fontUi:      Tokens.fontUi
    readonly property string fontDisplay: Tokens.fontDisplay

    readonly property int t2xs: Tokens.t2xs
    readonly property int txs:  Tokens.txs
    readonly property int tsm:  Tokens.tsm
    readonly property int tmd:  Tokens.tmd
    readonly property int tlg:  Tokens.tlg
    readonly property int txl:  Tokens.txl
    readonly property int t2xl: Tokens.t2xl
    readonly property int t3xl: Tokens.t3xl

    readonly property int s1: Tokens.s1
    readonly property int s2: Tokens.s2
    readonly property int s3: Tokens.s3
    readonly property int s4: Tokens.s4
    readonly property int s5: Tokens.s5
    readonly property int s6: Tokens.s6
    readonly property int s7: Tokens.s7
    readonly property int s8: Tokens.s8

    readonly property int radius:  Tokens.radius
    readonly property int radius2: Tokens.radius2
    readonly property int barH:    Tokens.barH
    readonly property int rowH:    Tokens.rowH
    readonly property int tap:     Tokens.tap

    readonly property int tFast: Tokens.tFast
    readonly property int tMed:  Tokens.tMed
    readonly property int tSlow: Tokens.tSlow

    readonly property QtObject lock: Tokens.lock
}
