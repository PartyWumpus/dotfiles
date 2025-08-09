import Quickshell
import QtQuick

MouseArea {
    id: root
    required property bool enabled
    required property string icon
    StyledText {
        color: root.enabled ? "white" : "grey"
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: icon
        font.pixelSize: 14
    }
}
