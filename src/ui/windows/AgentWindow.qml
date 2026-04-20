import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 520
    height: 700
    visible: false
    title: qsTr("Agent")
    color: "#0a0a0c"
    AIPromptPanel { anchors.fill: parent }
}
