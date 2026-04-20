import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    spacing: 8
    Label {
        text: qsTr("Color")
        color: "#ededef"
    }
    Rectangle {
        width: 28
        height: 28
        color: "#d4c9b0"
        border.color: "#1a1b1c"
    }
}
