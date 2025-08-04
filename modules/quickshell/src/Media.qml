pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell

PanelWindow {
  id: window
  exclusionMode: ExclusionMode.Ignore
  
  color: "transparent" 
  //color: Qt.rgba(1,0,0.8,0.2)
  mask: Region { item: root }
  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 180

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
          Layout.alignment: Qt.AlignTop
          id: media
          required property int index
          readonly property MprisPlayer player: Mpris.players.values[index]
          property bool expanded: false
          implicitWidth: rect.width
          implicitHeight: rect.height

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
            radius: 2

            color: Colors.surface0

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { 
                  expanded = true
                  rect.implicitHeight = rect.width;
                  imageEffect.saturation = 0.0;
                }
                onExited: { 
                  expanded = false
                  rect.implicitHeight = 19;
                  imageEffect.saturation = -1.0;
                }
            }

            Image {
              id: image
              retainWhileLoading: true
              anchors.centerIn: parent

              source: media.player.trackArtUrl ?? ""
              asynchronous: true
              fillMode: Image.PreserveAspectCrop
              sourceSize.width: rect.width
              sourceSize.height: rect.width
            }

            MultiEffect {
              id: imageEffect
              source: image
              anchors.fill: image
              saturation: -1.0


              Behavior on saturation {
                NumberAnimation {
                  duration: 500
                }
              }
            }

            WrapperItem {
              anchors.bottom: parent.bottom
              leftMargin: 1
              StyledText {
                font.pixelSize: 6
                font.bold: true
                style: Text.Outline
                styleColor: "black"
                text: media.player.trackArtist
              }
            }

            WrapperItem {
              anchors.bottom: parent.bottom
              anchors.right: parent.right
              rightMargin: 1
              StyledText {
                font.pixelSize: 6
                font.bold: true
                style: Text.Outline
                styleColor: "black"
                text: {
                  `${root.lengthStr(media.player.position)}/${root.lengthStr(media.player.length)}`
                }
              }
            }

            WrapperItem {
              anchors.top: parent.top
              topMargin: -1
              StyledText {
                id: title
                font.pixelSize: 10
                style: Text.Outline
                styleColor: "black"
                
                text: `${media.player.trackTitle}`

                SequentialAnimation {
                  running: rect.width-title.width < 0
                  loops:  Animation.Infinite
                  NumberAnimation { target: title; property: "x"; to: (rect.width-title.width)-2; duration: 2000 }
                  NumberAnimation { target: title; property: "x"; to: (rect.width-title.width)-2; duration: 2000 }
                  NumberAnimation { target: title; property: "x"; to: 2; duration: 2000 }
                  NumberAnimation { target: title; property: "x"; to: 2; duration: 2000 }
                }
              }
            }
          }
        }
      }
    }
  }
}
