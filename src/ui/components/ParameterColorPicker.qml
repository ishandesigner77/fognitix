import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

RowLayout {
    spacing: 8
    Theme { id: theme }

    Label {
        text: qsTr("Color")
        color: theme.colors.textPrimary
    }
    Rectangle {
        width: 28
        height: 28
        color: theme.colors.accent
        border.color: theme.colors.borderSoft
    }
}
