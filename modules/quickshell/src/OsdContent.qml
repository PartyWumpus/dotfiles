import QtQuick
import Quickshell.Services.Pipewire
import QtQuick.Controls

Rectangle {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    color: Colors.crust
    radius: 5
    width: 150
    height: 50

    StyledText {
        id: icon
        anchors.leftMargin: 10
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: {
            const audio = Pipewire.defaultAudioSink.audio;
            if (audio.muted) {
                "󰖁";
            } else if (audio.volume > 0.66) {
                "";
            } else if (audio.volume > 0.33) {
                "󰖀";
            } else {
                "󰕿";
            }
        }
    }

    ProgressBar {
        id: control
        anchors.left: icon.right
        anchors.right: text.left
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 12
            color: Colors.surface0
            radius: 8
        }

        contentItem: Item {
            implicitWidth: 200
            implicitHeight: 8

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: 8
                color: Colors.mauve
            }
        }
        value: Pipewire.defaultAudioSink.audio.volume
    }

    Item {
        id: text
        width: 45
        anchors.rightMargin: 5
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: `${Math.round(Pipewire.defaultAudioSink.audio.volume * 100)}%`
        }
    }
}
