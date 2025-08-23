pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string show_clipboard: json.show_clipboard
  property string wifi_menu: json.wifi_menu
  property string bluetooth_menu: json.bluetooth_menu
  property string record: json.record

  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.local/share/qs/nix.json"

    blockLoading: true

    Component.onCompleted: {
      reload()
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
