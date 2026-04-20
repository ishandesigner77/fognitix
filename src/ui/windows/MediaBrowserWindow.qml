import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 960
    height: 640
    visible: false
    title: qsTr("Media")
    color: "#0a0a0c"

    Grid {
        anchors.fill: parent
        anchors.margins: 12
        columns: 6
        spacing: 8
        Repeater {
            model: 18
            MediaThumbnail {}
        }
    }
}
