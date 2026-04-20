import QtQuick
import QtQuick.Controls
import Fognitix

TextField {
    id: root

    Theme { id: theme }

    implicitHeight: 32
    leftPadding: 10
    rightPadding: 10
    verticalAlignment: TextInput.AlignVCenter
    color: theme.colors.textPrimary
    placeholderTextColor: theme.colors.textDisabled
    font.pixelSize: theme.typography.body
    font.family: theme.typography.fontFamily
    selectByMouse: true

    background: Rectangle {
        implicitHeight: 32
        radius: 6
        color: theme.colors.aiPanelDeep
        border.color: root.activeFocus ? theme.colors.borderFocus : theme.colors.borderHairline
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
}
