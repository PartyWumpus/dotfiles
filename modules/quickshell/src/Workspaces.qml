pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Item {
    id: root

    readonly property var workspaces: {
      const wks = {}
      Hyprland.workspaces.values.forEach((wk) => {
        wks[wk.id-1] = wk
      })
      wks
    }
      
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.verticalCenter: parent.verticalCenter

        spacing: 3

        Repeater {
            model: 10 

            Rectangle {
              required property int index
              width: 14
              height: 14
              radius: Infinity
              color: {
                const wk = root.workspaces[this.index]
                // TODO: handle multimonitor
                if (wk === undefined) {
                  Colors.surface1
                } else if (wk.focused) {
                  Colors.mauve
                } else if (wk.urgent) {
                  Colors.red
                } else {
                  Colors.overlay1
                }
              }
            } 
        }
    }

    MouseArea {
        anchors.fill: parent

        onPressed: event => {
            const ws = layout.childAt(event.x, event.y).index + 1;
            if (Hyprland.focusedWorkspace !== ws)
                Hyprland.dispatch(`workspace ${ws}`);
        }
    }
}
