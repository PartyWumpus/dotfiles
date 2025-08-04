import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
  Variants {
    model: Quickshell.screens

    Scope {
      id: base
      required property var modelData
      Wallpaper {}


      PanelWindow {
        id: bar
        screen: base.modelData
        color: Colors.crust

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 20

        WrapperItem {
          anchors.verticalCenter: parent.verticalCenter
          leftMargin: 4
          RowLayout {
            Workspaces {}
          }
        }

        RowLayout {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right

          Battery {}
          Clock {}
        }
      }


      Media {}
    }
  }
}
