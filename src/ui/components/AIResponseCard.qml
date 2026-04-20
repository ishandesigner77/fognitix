import QtQuick
import QtQuick.Controls

Rectangle {
    property string body: ""
    color: "#161619"
    border.color: "#1a1b1c"
    radius: 8
    height: 72

    Label {
        anchors.margins: 10
        anchors.fill: parent
        wrapMode: Text.Wrap
        text: body
        color: "#ededef"
        font.pixelSize: 12
    }
}
