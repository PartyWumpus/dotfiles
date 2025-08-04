import QtQuick
import QtQuick.Effects

MultiEffect {
    anchors.fill: source
    colorization: 1
    brightness: 1
    required property color color
    colorizationColor: color

    /*Behavior on colorizationColor {
        ColorAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }*/
}
