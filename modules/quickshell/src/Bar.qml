// Disables the reload popup
//@ pragma Env QS_NO_RELOAD_POPUP=1

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

                // This mask intentionally does NOT include the media dropdowns
                mask: Region {
                    Region {
                        item: bar
                    }
                    Region {
                        item: hotcorner
                    }
                }

                Item {
                    id: root
                    anchors.fill: parent

                    // This applies the "shadow" effect at the edges
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        blurMax: 10
                        shadowColor: Qt.alpha(Colors.mauve, 0.7)
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

                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            implicitHeight: 20
                            implicitWidth: battery.implicitWidth + hotcornerContainer.implicitWidth

                            Rectangle {
                                id: wawaAreaa
                                color: "transparent"
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: content.implicitWidth - 5
                                height: 15
                                MouseArea {
                                    id: wawaArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }

                            Item {
                                id: battery
                                anchors.left: parent.left
                                implicitWidth: batteryInner.implicitWidth + 5
                                Battery {
                                    id: batteryInner
                                    anchors.left: parent.left
                                }
                            }
                            Item {
                                id: hotcornerContainer
                                anchors.left: battery.right
                                implicitWidth: clock.implicitWidth + hotcorner.implicitWidth
                                implicitHeight: Math.max(clock.implicitHeight, hotcorner.implicitHeight)

                                Clock {
                                    id: clock
                                    anchors.left: parent.left
                                }
                                MouseArea {
                                    id: hotcornerArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    Item {
                                        id: hotcorner
                                        anchors.right: parent.right
                                        implicitHeight: content.implicitHeight
                                        visible: implicitWidth > 0
                                        implicitWidth: 0
                                        y: -content.implicitHeight

                                        states: State {
                                            name: "visible"
                                            when: wawaArea.containsMouse || hotcornerArea.containsMouse

                                            PropertyChanges {
                                                hotcorner.implicitWidth: content.implicitWidth
                                                hotcorner.y: 0
                                            }
                                        }

                                        transitions: [
                                            Transition {
                                                from: ""
                                                to: "visible"

                                                NumberAnimation {
                                                    target: hotcorner
                                                    property: "implicitWidth"
                                                    duration: 150
                                                    easing.type: Easing.Linear
                                                }
                                                NumberAnimation {
                                                    target: hotcorner
                                                    property: "y"
                                                    duration: 150
                                                    easing.type: Easing.OutCirc
                                                }
                                            },
                                            Transition {
                                                from: "visible"
                                                to: ""

                                                SequentialAnimation {
                                                    PauseAnimation {
                                                        duration: 200
                                                    }
                                                    ParallelAnimation {
                                                        NumberAnimation {
                                                            target: hotcorner
                                                            property: "implicitWidth"
                                                            duration: 200
                                                            easing.type: Easing.InOutQuad
                                                        }
                                                        NumberAnimation {
                                                            target: hotcorner
                                                            property: "y"
                                                            duration: 200
                                                            easing.type: Easing.InOutQuad
                                                        }
                                                    }
                                                }
                                            }
                                        ]

                                        HotcornerContent {
                                            id: content
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Media {}
                }
            }
        }
    }
}
