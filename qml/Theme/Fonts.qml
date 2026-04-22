pragma Singleton
import QtQuick

QtObject {
    //  Fonts is a facade that ensures font families referenced by Theme
    //  are loaded if shipped inside the repo. Söhne Mono and Inria Serif
    //  are commercial and not redistributed here; at runtime the stack
    //  collapses to JetBrains Mono + a system serif. Add FontLoader {}
    //  entries here if the repo ever vendors fonts/*.ttf.
    readonly property bool ready: true
    readonly property string ui:      "Söhne Mono, JetBrains Mono, Berkeley Mono, monospace"
    readonly property string display: "Inria Serif, Source Serif 4, Charter, Georgia, serif"
}
