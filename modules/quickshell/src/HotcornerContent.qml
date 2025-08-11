import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    radius: 8
    implicitWidth: 100
    implicitHeight: 100
    color: Colors.crust
    StyledText {
        anchors.bottom: root.bottom
        anchors.left: root.left
        text: "wah"
    }
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        MediaButton {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            icon: ""
            enabled: true
            implicitWidth: 15
            implicitHeight: 15
            onClicked: () => {
                media.player.next();
            }
        }
        MediaButton {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            icon: ""
            enabled: true
            implicitWidth: 15
            implicitHeight: 15
            onClicked: () => {
                media.player.next();
            }
        }
        MediaButton {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            icon: ""
            enabled: true
            implicitWidth: 15
            implicitHeight: 15
            onClicked: () => {
                media.player.next();
            }
        }
    }
}
