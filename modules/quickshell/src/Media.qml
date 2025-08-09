pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick.Effects
import Quickshell

WrapperItem {
    id: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    topMargin: 1
    function lengthStr(length: int): string {
        if (length <= 0) {
            return `-:--`;
        }
        const min = Math.floor(length / 60);
        const sec = Math.floor(length % 60);
        const sec0 = sec < 10 ? "0" : "";
        return `${min}:${sec0}${sec}`;
    }

    RowLayout {
        id: layout
        spacing: 7

        Repeater {
            model: Mpris.players.values.length

            Item {
                id: media
                Layout.alignment: Qt.AlignTop
                required property int index
                readonly property MprisPlayer player: Mpris.players.values[index]
                property bool expanded: false
                implicitWidth: rect.width
                implicitHeight: rect.height
                visible: {
                    !(player.title === undefined && player.artist === undefined && player.position === 0);
                }

                Timer {
                    // only emit the signal when the position is actually changing.
                    running: media.player.playbackState == MprisPlaybackState.Playing
                    // Make sure the position updates at least once per second.
                    interval: 1000
                    repeat: true
                    // emit the positionChanged signal every second.
                    onTriggered: media.player.positionChanged()
                }

                ClippingRectangle {
                    id: rect
                    implicitWidth: 150
                    implicitHeight: 18
                    Behavior on implicitHeight {
                        SequentialAnimation {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }
                    bottomLeftRadius: 5
                    bottomRightRadius: 5

                    color: Colors.crust

                    MouseArea {
                        id: wawaw
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            expanded = true;
                            rect.implicitHeight = 19 * 2;
                        }
                        onExited: {
                            expanded = false;
                            rect.implicitHeight = 18;
                        }

                        WrapperItem {
                            id: wawa
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            bottomMargin: 20
                            leftMargin: 5
                            rightMargin: 5

                            RowLayout {
                                Layout.fillWidth: true
                                Image {
                                    id: albumIcon
                                    Layout.alignment: Qt.AlignCenter
                                    retainWhileLoading: true

                                    source: media.player.trackArtUrl ?? ""
                                    asynchronous: true
                                    fillMode: Image.Stretch
                                    sourceSize.width: 15
                                    sourceSize.height: 15
                                }
                                MediaButton {
                                    Layout.alignment: Qt.AlignCenter
                                    icon: "󰒮"
                                    enabled: media.player.canGoPrevious
                                    implicitWidth: 15
                                    implicitHeight: 15
                                    onClicked: () => {
                                        media.player.previous();
                                    }
                                }
                                MediaButton {
                                    Layout.alignment: Qt.AlignCenter
                                    icon: media.player.isPlaying ? "" : ""
                                    enabled: media.player.canTogglePlaying
                                    implicitWidth: 15
                                    implicitHeight: 15
                                    onClicked: () => {
                                        media.player.togglePlaying();
                                    }
                                }
                                MediaButton {
                                    Layout.alignment: Qt.AlignCenter
                                    icon: "󰒭"
                                    enabled: media.player.canGoNext
                                    implicitWidth: 15
                                    implicitHeight: 15
                                    onClicked: () => {
                                        media.player.next();
                                    }
                                }
                                MouseArea {
                                    id: mediaPlayerIconArea
                                    Layout.alignment: Qt.AlignCenter
                                    implicitHeight: 15
                                    implicitWidth: 15
                                    hoverEnabled: true
                                    onClicked: () => {
                                        const playerMaps = {
                                            Chrome: "initialclass:google-chrome",
                                            Spotify: "initialclass:[sS]potify"
                                        };
                                        // TODO: do this less badly?
                                        Hyprland.dispatch(`focuswindow ${playerMaps[player.identity]}`);
                                        //media.player.raise();
                                    }
                                    ToolTip {
                                        text: player.identity
                                        visible: mediaPlayerIconArea.containsMouse
                                    }
                                    IconImage {
                                        id: mediaPlayerIcon
                                        anchors.fill: parent
                                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(media.player.identity)?.icon ?? "", "todo-use-generic-music-icon")
                                        asynchronous: true
                                    }
                                }
                            }
                        }

                        WrapperItem {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            rightMargin: 1
                            StyledText {
                                font.pixelSize: 6
                                font.bold: true
                                text: {
                                    `${root.lengthStr(media.player.position)}/${root.lengthStr(media.player.length)}`;
                                }
                            }
                        }

                        WrapperItem {
                            anchors.bottom: parent.bottom
                            leftMargin: 1
                            StyledText {
                                font.pixelSize: 6
                                font.bold: true
                                text: media.player.trackArtist
                            }
                        }

                        WrapperItem {
                            anchors.bottom: parent.bottom
                            bottomMargin: 6
                            StyledText {
                                id: title
                                font.pixelSize: 11
                                text: `${media.player.trackTitle}`
                                clip: true

                                SequentialAnimation {
                                    running: rect.width - title.width < 0
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        target: title
                                        property: "x"
                                        to: (rect.width - title.width) - 2
                                        duration: 2000
                                    }
                                    PauseAnimation {
                                        duration: 5000
                                    }
                                    NumberAnimation {
                                        target: title
                                        property: "x"
                                        to: 2
                                        duration: 2000
                                    }
                                    PauseAnimation {
                                        duration: 5000
                                    }
                                }

                                SequentialAnimation {
                                    running: rect.width - title.width >= 0
                                    NumberAnimation {
                                        target: title
                                        property: "x"
                                        to: (rect.width - title.width) / 2
                                        duration: 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
