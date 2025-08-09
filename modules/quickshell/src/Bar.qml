import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import Quickshell.Wayland

Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: base
            required property var modelData

            // This is just to reserve the top 20 pixels of the screen
            PanelWindow {
                implicitHeight: 20
                anchors {
                    top: true
                    left: true
                    right: true
                }
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Bottom
            }

            // This is what contains the actual content
            PanelWindow {
                screen: base.modelData
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                mask: Region {
                    item: bar
                }

                Item {
                    id: root
                    anchors.fill: parent

                    // This applies the "shadow" effect at the edges
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        blurMax: 15
                        shadowColor: Qt.alpha("white", 0.7)
                    }

                    Border {}

                    Item {
                        id: bar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        implicitHeight: 20
                        Rectangle {
                            anchors.fill: parent
                            implicitHeight: 20
                            color: Colors.crust
                        }
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
    }
}
