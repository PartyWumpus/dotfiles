import QtQuick
import QtQuick.Controls.Basic

ToolTip {
    id: control

    contentItem: StyledText {
        text: control.text
        font: control.font
    }

    background: Rectangle {
        border.color: Colors.mauve
        color: Colors.crust
        radius: 4
    }
}
