import Quickshell
import QtQuick
import QtQuick.Effects

Item {
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: Colors.crust

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 20
            radius: 8
        }
    }
}
