import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Services.Pipewire

Item {
    id: root

    property var cornerWidth: 15
    property var cornerHeight: 15
    property bool visibility

    implicitHeight: 0
    implicitWidth: content.implicitWidth
    anchors.leftMargin: -content.width

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            root.visibility = true;
            hideTimer.restart();
        }

        function onMutedChanged() {
            root.visibility = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: root.visibility = false
    }

    states: State {
        name: "visible"
        when: root.visibility

        PropertyChanges {
            root.anchors.leftMargin: 0
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root.anchors
                property: "leftMargin"
                duration: 100
                easing.type: Easing.OutCirc
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root.anchors
                property: "leftMargin"
                duration: 300
                easing.type: Easing.InCirc
            }
        }
    ]

    OsdContent {
        id: content
    }

    Rectangle {
        color: Colors.crust
        anchors.bottom: bottomRightCorner.bottom
        anchors.left: bottomRightCorner.left
        anchors.right: bottomRightCorner.right
        width: bottomRightCorner.width
        height: 8
    }

    Shape {
        id: bottomRightCorner
        asynchronous: true
        preferredRendererType: Shape.CurveRenderer
        width: 15
        height: 15

        anchors.left: content.right
        anchors.bottom: parent.bottom

        ShapePath {
            startX: 0
            startY: 0
            strokeWidth: -1
            fillColor: Colors.crust

            PathArc {
                x: root.cornerWidth
                y: root.cornerHeight
                radiusX: root.cornerWidth
                radiusY: root.cornerHeight
            }
            PathLine {
                x: root.cornerWidth
                y: 0
            }
        }
        transform: Rotation {
            origin.x: root.cornerWidth / 2
            origin.y: (root.cornerHeight - 7.5) / 2
            angle: 2 * -90
        }
    }

    Shape {
        id: topLeftCorner
        asynchronous: true
        preferredRendererType: Shape.CurveRenderer
        width: 15
        height: 15

        anchors.bottom: content.top
        anchors.left: parent.left

        ShapePath {
            startX: 0
            startY: 0
            strokeWidth: -1
            fillColor: Colors.crust
            //fillColor: "orange"

            PathArc {
                x: root.cornerWidth
                y: root.cornerHeight
                radiusX: root.cornerWidth
                radiusY: root.cornerHeight
            }
            PathLine {
                x: root.cornerWidth
                y: 0
            }
        }
        transform: Rotation {
            origin.x: (root.cornerWidth + 7.5) / 2
            origin.y: (root.cornerHeight) / 2
            angle: 2 * -90
        }
    }
}
