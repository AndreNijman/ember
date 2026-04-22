import QtQuick
import Quickshell
import "Modules/Shell"
import "Services"

ShellRoot {
    id: root
    //  Root entry: instantiates ShellRoot which owns every surface.
    //  Services (Ipc, Clock, Hypr, Power, Audio, etc.) auto-register
    //  because they're singletons referenced transitively.
    Component.onCompleted: {
        Ipc.shell.target  // touch so the handler registers
    }
}
