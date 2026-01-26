import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    FileView {
        id: recording
        property bool recording: false
        watchChanges: true
        printErrors: false
        path: Qt.resolvedUrl(Quickshell.env("HOME") + "/.recording")

        onFileChanged: this.reload()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                this.recording = false;
            } else {
                console.warn("Recording fileview failed:", FileViewError.toString(err));
            }
        }
        onLoaded: this.recording = true
    }

    property bool recording: recording.recording

    StyledText {
        id: layout
        text: root.recording ? " 🔴 " : null
    }
}
