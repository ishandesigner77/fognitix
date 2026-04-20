import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 480
    height: 640
    visible: false
    title: qsTr("Effects")
    color: "#0a0a0c"
    EffectsPanel { anchors.fill: parent }
}
