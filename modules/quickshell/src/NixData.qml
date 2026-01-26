pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property alias show_clipboard: json.show_clipboard
    property alias wifi_menu: json.wifi_menu
    property alias bluetooth_menu: json.bluetooth_menu
    property alias record: json.record

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.local/share/qs/nix.json"

        blockLoading: true
        preload: true

        Component.onCompleted: {
            // file.reload() only works the second time
            // idfk
            file.data();
        }

        JsonAdapter {
            id: json
            property string show_clipboard
            property string wifi_menu
            property string bluetooth_menu
            property string record
        }
    }
}
