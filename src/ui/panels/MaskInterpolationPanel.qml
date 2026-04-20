import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surfaceRaised
            border.width: 1
            border.color: theme.colors.borderSoft

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: theme.spacing.md
                text: "MASK INTERPOLATION"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: theme.spacing.sm

                Item { height: theme.spacing.sm }

                // Info label
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: infoText.implicitHeight + theme.spacing.sm * 2
                    color: theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        id: infoText
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top; margins: theme.spacing.sm
                        }
                        text: "Sets how masks interpolate between keyframes."
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textDim
                        wrapMode: Text.WordWrap
                    }
                }

                // Method combo
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    Text { text: "Method"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 100 }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Smart", "None", "Linear", "Curve"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // First Vertex Rotation
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    CheckBox {
                        id: fvRotCb
                        text: "First Vertex Rotation"
                        font.pixelSize: theme.typography.small
                        contentItem: Text {
                            leftPadding: fvRotCb.indicator.width + 6
                            text: fvRotCb.text; font: fvRotCb.font
                            color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 64; height: 24
                        color: theme.colors.surface
                        border.width: 1; border.color: theme.colors.borderSoft
                        radius: 2
                        enabled: fvRotCb.checked
                        opacity: enabled ? 1.0 : 0.4

                        TextInput {
                            anchors.fill: parent; anchors.margins: 6
                            text: "0"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            selectByMouse: true
                        }
                    }
                    Text { text: "\u00B0"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                }

                // Bending Resistance slider
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    RowLayout {
                        Text { text: "Bending Resistance"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: bendLabel
                            text: "0"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100; value: 0
                        height: 24
                        onValueChanged: bendLabel.text = Math.round(value)
                        background: Rectangle {
                            x: parent.leftPadding; y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth; height: 2; color: theme.colors.borderSoft; radius: 1
                            Rectangle { width: parent.parent.visualPosition * parent.width; height: 2; color: theme.colors.accent; radius: 1 }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 12; height: 12; radius: 6; color: theme.colors.accent
                        }
                    }
                }

                // Deform Rate spinner
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    Text { text: "Deform Rate"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 100 }

                    Rectangle {
                        width: 70; height: 24
                        color: theme.colors.surface
                        border.width: 1; border.color: theme.colors.borderSoft
                        radius: 2

                        TextInput {
                            anchors.fill: parent; anchors.margins: 6
                            text: "1.0"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            selectByMouse: true
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Apply button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 30
                    color: miApplyMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                    radius: 2

                    Text { anchors.centerIn: parent; text: "Apply"; font.pixelSize: theme.typography.small; font.weight: Font.Medium; color: theme.colors.textOnAccent }
                    MouseArea { id: miApplyMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // MASK FEATHER KEYFRAMES section
                Text {
                    text: "MASK FEATHER KEYFRAMES"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                    Layout.leftMargin: theme.spacing.md
                }

                // Add feather point button
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    Rectangle {
                        implicitWidth: addFeatherLbl.implicitWidth + theme.spacing.md * 2
                        height: 26
                        color: addFeatherMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                        border.width: 1; border.color: theme.colors.borderSoft
                        radius: 2

                        Text {
                            id: addFeatherLbl
                            anchors.centerIn: parent
                            text: "+ Add Feather Point"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                        MouseArea { id: addFeatherMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Placeholder list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 60
                    color: theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: "No feather keyframes"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textDim
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
