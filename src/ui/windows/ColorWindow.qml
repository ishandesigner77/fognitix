import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 1100
    height: 700
    visible: false
    title: qsTr("Color")
    color: "#0a0a0c"
    Row {
        anchors.fill: parent
        ScopesPanel { width: parent.width * 0.35; height: parent.height }
        ColorPanel { width: parent.width * 0.65; height: parent.height }
    }
}
