import QtQuick
import QtQuick.Controls
import Fognitix

Button {
    id: root

    /// "primary" | "secondary" | "ghost"
    property string variant: "secondary"

    Theme { id: theme }

    implicitHeight: Math.max(32, contentItem.implicitHeight + topPadding + bottomPadding)
    leftPadding: 12
    rightPadding: 12
    topPadding: 8
    bottomPadding: 8
    font.pixelSize: theme.typography.button
    font.family: theme.typography.fontFamily

    flat: root.variant === "ghost"

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    scale: root.pressed ? 0.97 : 1

    background: Rectangle {
        radius: 6
        border.width: root.variant === "ghost" ? 0 : 1
        border.color: theme.colors.borderHairline
        color: {
            if (root.variant === "primary") {
                if (!root.enabled)
                    return theme.colors.elevated
                return root.hovered ? theme.colors.accentHover : theme.colors.accent
            }
            if (root.variant === "ghost") {
                if (root.hovered)
                    return Qt.lighter(theme.colors.panelElevated, 1.08)
                return "transparent"
            }
            if (!root.enabled)
                return theme.colors.elevated
            return root.hovered ? Qt.lighter(theme.colors.panelElevated, 1.06) : theme.colors.panelElevated
        }
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    contentItem: Text {
        text: root.text
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: {
            if (root.variant === "primary")
                return "#ffffff"
            return root.enabled ? theme.colors.textSecondary : theme.colors.textDisabled
        }
    }
}
