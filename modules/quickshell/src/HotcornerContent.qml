import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs
import QtQuick.Controls
import Quickshell.Widgets

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
        id: buttons
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
                Quickshell.execDetached(NixData.wifi_menu);
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
                Quickshell.execDetached(NixData.bluetooth_menu);
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
                Quickshell.execDetached("wlogout");
            }
        }
    }
    RowLayout {
        id: audioOutputs
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: buttons.bottom

        Repeater {
            model: Audio.sinks

            Item {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                implicitHeight: {
                  children[0].implicitHeight
                }

                required property PwNode modelData
                MouseArea {
                    id: mediaPlayerIconArea

                    implicitHeight: 15
                    implicitWidth: 15
                    hoverEnabled: true
                    onClicked: {
                      Audio.setAudioSink(modelData)
                    }
                    ToolTip {
                        text: {
                            (modelData.description === '' ? modelData.name : modelData.description) + PwNodeType.toString(modelData.type);
                        }
                        visible: {
                            mediaPlayerIconArea.containsMouse;
                        }
                    }
                    IconImage {
                        id: mediaPlayerIcon
                        anchors.fill: parent
                        source: Quickshell.iconPath(Audio.getIcon(modelData), "todo-use-generic-music-icon")
                        asynchronous: true
                    }
                }
            }
        }
    }
}
