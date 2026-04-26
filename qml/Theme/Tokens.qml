pragma Singleton
import QtQuick

QtObject {
    // --- ink ramp ------------------------------------------------------
    readonly property color ink0: "#0E0F11"
    readonly property color ink1: "#14161A"
    readonly property color ink2: "#1A1D22"
    readonly property color ink3: "#22262C"
    readonly property color ink4: "#2F343B"
    readonly property color ink5: "#4A5058"
    readonly property color ink6: "#7C838C"
    readonly property color ink7: "#B3B7BC"
    readonly property color ink8: "#E8EAEC"

    // --- hairlines -----------------------------------------------------
    readonly property color hair:    "#2A2E33"
    readonly property color hairDim: "#181A1D"
    readonly property int   hairW:   1

    // --- accent --------------------------------------------------------
    readonly property color accent:    "#F2A33C"
    readonly property color accentDim: Qt.rgba(0.949, 0.639, 0.235, 0.32)
    readonly property color accentFg:  "#0E0F11"

    // --- brand (IdentityGlyph idle vs hover) ---------------------------
    readonly property color brand:      "#E8EAEC"
    readonly property color brandHover: "#F2A33C"

    // --- status --------------------------------------------------------
    readonly property color ok:   "#6FB37A"
    readonly property color warn: "#D9A441"
    readonly property color err:  "#D86D5C"

    // --- fonts ---------------------------------------------------------
    //  Söhne Mono preferred; fall back to JetBrains Mono -> Berkeley Mono
    //  -> ui-monospace / monospace. Serif: Inria Serif -> Source Serif 4
    //  -> Charter -> Georgia -> generic serif.
    readonly property string fontUi:      "Söhne Mono, JetBrains Mono, Berkeley Mono, monospace"
    readonly property string fontDisplay: "Inria Serif, Source Serif 4, Charter, Georgia, serif"

    // --- type scale (pt-less; we store px) -----------------------------
    readonly property int t2xs: 10
    readonly property int txs:  11
    readonly property int tsm:  12
    readonly property int tmd:  14
    readonly property int tlg:  18
    readonly property int txl:  24
    readonly property int t2xl: 36
    readonly property int t3xl: 96
    readonly property int tLockClock: 128

    // --- spacing (px) --------------------------------------------------
    readonly property int s1: 4
    readonly property int s2: 8
    readonly property int s3: 12
    readonly property int s4: 16
    readonly property int s5: 24
    readonly property int s6: 32
    readonly property int s7: 48
    readonly property int s8: 64

    // --- geometry ------------------------------------------------------
    readonly property int radius:  0
    readonly property int radius2: 2
    readonly property int barH:    28
    readonly property int rowH:    32
    readonly property int tap:     40

    // --- motion (ms) ---------------------------------------------------
    readonly property int tFast: 120
    readonly property int tMed:  240
    readonly property int tSlow: 320
    //  QML has no cubic-bezier token type; consumers use Easing.BezierSpline
    //  with the four control points below. (0.2,0) -> (0,1) shape.
    readonly property var easeCubic: [0.2, 0, 0, 1]

    // --- lock surface --------------------------------------------------
    readonly property QtObject lock: QtObject {
        readonly property int clockSize: 128
    }
}
