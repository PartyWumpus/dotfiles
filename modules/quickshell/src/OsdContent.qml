import QtQuick

Rectangle {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    color: Colors.crust
    radius: 5
    width: 150
    height: 50

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "volume 100%"
    }
}
