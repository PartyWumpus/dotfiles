import Quickshell
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property var cornerWidth: 15
    property var cornerHeight: 15
    required property bool visibility

    //visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    states: State {
        name: "visible"
        when: root.visibility

        PropertyChanges {
            root.y: 200 
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "y"
                duration: 200
                easing.type: Easing.BezierSpline
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "y"
                duration: 200
                easing.type: Easing.BezierSpline
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
