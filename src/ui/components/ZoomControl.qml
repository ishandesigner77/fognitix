import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

RowLayout {
    id: root
    spacing: 4

    property alias zoomFactor: zoomSlider.value
    signal zoomRequested(real value)

    Theme { id: theme }

    Label {
        text: "\u2212"
        color: theme.colors.textSecondary
        font.pixelSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.25)
            cursorShape: Qt.PointingHandCursor
        }
    }

    Slider {
        id: zoomSlider
        from: 0.25; to: 4.0; value: 1.0
        implicitWidth: 90
        implicitHeight: 18
        stepSize: 0.05

        background: Rectangle {
            x: zoomSlider.leftPadding; y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
            width: zoomSlider.availableWidth; height: 3
            color: theme.colors.borderColor; radius: 2
            Rectangle {
                width: zoomSlider.visualPosition * parent.width
                height: parent.height; color: theme.colors.accent; radius: 2
            }
        }
        handle: Rectangle {
            x: zoomSlider.leftPadding + zoomSlider.visualPosition * (zoomSlider.availableWidth - width)
            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
            width: 12; height: 12
            radius: 6
            color: zoomSlider.pressed ? theme.colors.accentHover : theme.colors.accent
        }

        onValueChanged: root.zoomRequested(value)
    }

    Label {
        text: "\u002B"
        color: theme.colors.textSecondary
        font.pixelSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.25)
            cursorShape: Qt.PointingHandCursor
        }
    }

    Label {
        text: Math.round(zoomSlider.value * 100) + "%"
        color: theme.colors.textDisabled
        font.pixelSize: theme.typography.caption
        font.family: "Consolas"
        width: 36
    }
}
