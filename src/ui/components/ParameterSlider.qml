import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    property string label: ""
    property real value: 0.5

    Label {
        text: label
        color: "#95969a"
        font.pixelSize: 11
    }

    Slider {
        Layout.fillWidth: true
        from: 0
        to: 1
        value: parent.value
    }
}
