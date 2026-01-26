import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    RowLayout {
        id: layout
        spacing: 3
        StyledText {
            text: Time.time
        }
        StyledText {
            text: Time.date
        }
    }
}
