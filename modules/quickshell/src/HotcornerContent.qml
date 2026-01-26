import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import qs
import QtQuick.Controls
import Quickshell.Widgets

Rectangle {
    id: root
    radius: 8
    implicitWidth: 100
    implicitHeight: 100
    color: Colors.crust

    RowLayout {
        id: buttons
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            implicitHeight: 25
            MediaButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                icon: ""
                enabled: true
                implicitWidth: 25
                implicitHeight: 25
                onClicked: () => {
                    console.log(NixData.wifi_menu);
                    Quickshell.execDetached(NixData.wifi_menu);
                }
            }
        }
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            implicitHeight: 25
            MediaButton {
                icon: ""
                enabled: true
                implicitWidth: 25
                implicitHeight: 25
                onClicked: () => {
                    Quickshell.execDetached(NixData.bluetooth_menu);
                }
            }
        }
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            implicitHeight: 25
            MediaButton {
                icon: ""
                enabled: true
                implicitWidth: 25
                implicitHeight: 25
                onClicked: () => {
                    Quickshell.execDetached("wlogout");
                }
            }
        }
    }
    RowLayout {
        id: audioOutputs
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: buttons.bottom

        Repeater {
            model: Audio.sinks

            Item {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                implicitHeight: {
                    children[0].implicitHeight;
                }

                required property PwNode modelData

                // not needed because we already track all sinks in Audio.qml
                // PwObjectTracker { objects: [ modelData ] }

                MouseArea {
                    id: mediaPlayerIconArea
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    implicitHeight: 25
                    implicitWidth: 25
                    hoverEnabled: true
                    onClicked: {
                        Audio.setAudioSink(modelData);
                    }
                    StyledToolTip {
                        text: {
                            (modelData.description === '' ? modelData.name : modelData.description);
                        }
                        visible: {
                            mediaPlayerIconArea.containsMouse;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        border.color: modelData.id === Audio.defaultSink.id ? Colors.mauve : "transparent"
                        color: {
                            if (mediaPlayerIconArea.containsPress) {
                                Colors.mauve;
                            } else if (mediaPlayerIconArea.containsMouse) {
                                Colors.surface2;
                            } else {
                                Colors.surface1;
                            }
                        }
                        radius: 8
                    }

                    IconImage {
                        id: mediaPlayerIcon
                        anchors.fill: parent

                        anchors.margins: 5

                        source: {
                            const icon = Quickshell.iconPath(modelData.properties["device.icon-name"], true);

                            if (icon !== "") {
                                return icon;
                            }

                            /*
                          const device = ... get from modelData.properties["device.id"]
                          switch (device.properties["device.form-factor"]) {
                            case "headphone":
                            case "headset":
                              return Quickshell.iconPath("audio-headphones");
                            case "webcam":
                            case "handset":
                            case "hands-free":
                            case "portable":
                              return Quickshell.iconPath("audio-handsfree");
                            case "speaker":
                            case "computer":
                            case "hifi":
                            case undefined:
                              return Quickshell.iconPath("audio-speakers");
                            case "internal":
                            case "microphone":
                            case "tv":
                            case "car":
                              return Quickshell.iconPath("audio-unknown");
                            }
                          */
                            return Quickshell.iconPath("audio-speakers");
                        }
                        asynchronous: true
                    }
                }
            }
        }
    }

    RowLayout {
        id: bluetoothDevices
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: audioOutputs.bottom

        Repeater {
            model: Bluetooth.devices

            Item {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                visible: modelData.trusted
                implicitHeight: {
                    children[0].implicitHeight;
                }

                required property BluetoothDevice modelData

                MouseArea {
                    id: mediaPlayerIconArea
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    implicitHeight: 25
                    implicitWidth: 25
                    hoverEnabled: true
                    onClicked: {
                        modelData.connected = !modelData.connected;
                    }
                    StyledToolTip {
                        text: {
                            (modelData.deviceName);
                        }
                        visible: {
                            mediaPlayerIconArea.containsMouse;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        border.color: {
                            if (modelData.state === BluetoothDeviceState.Connected) {
                                Colors.mauve;
                            } else if (modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting) {
                                Colors.sky;
                            } else {
                                "transparent";
                            }
                        }
                        color: {
                            if (mediaPlayerIconArea.containsPress) {
                                Colors.mauve;
                            } else if (mediaPlayerIconArea.containsMouse) {
                                Colors.surface2;
                            } else {
                                Colors.surface1;
                            }
                        }
                        radius: 8
                    }

                    IconImage {
                        id: mediaPlayerIcon
                        anchors.fill: parent

                        anchors.margins: 5

                        source: {
                            const icon = Quickshell.iconPath(modelData.icon, true);

                            if (icon !== "") {
                                return icon;
                            }

                            return Quickshell.iconPath("bluetooth");
                        }
                        asynchronous: true
                    }
                }
            }
        }
    }
}
