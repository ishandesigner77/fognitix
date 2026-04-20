import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 900
    height: 620
    visible: false
    title: qsTr("Analytics")
    color: "#0a0a0c"
    Label {
        anchors.centerIn: parent
        text: qsTr("AI pacing, color consistency, engagement predictions")
        color: "#95969a"
        horizontalAlignment: Text.AlignHCenter
    }
}
