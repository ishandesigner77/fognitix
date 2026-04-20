import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 1000
    height: 600
    visible: false
    title: qsTr("Audio")
    color: "#0a0a0c"
    AudioMixerPanel { anchors.fill: parent }
}
