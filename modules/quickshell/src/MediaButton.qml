import Quickshell
import QtQuick

MouseArea {
    id: root
    property bool enabled: true
    required property string icon
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        color: {
            if (root.containsPress) {
                Colors.mauve;
            } else if (root.containsMouse) {
                Colors.surface2;
            } else {
                Colors.surface1;
            }
        }
        radius: 8
    }

    StyledText {
        color: root.enabled ? "white" : "grey"
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: icon
        font.pixelSize: 14
    }
}
