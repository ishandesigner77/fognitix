import QtQuick
import QtQuick.Controls

Rectangle {
    property string title: ""
    color: "#161619"
    border.color: "#1a1b1c"
    radius: 6
    height: 64

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: title
        color: "#ededef"
    }
}
