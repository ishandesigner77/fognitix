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

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.md
                anchors.rightMargin: theme.spacing.sm

                Text {
                    text: "ALIGN & DISTRIBUTE"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                }
                Item { Layout.fillWidth: true }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 0

                // Align To row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: theme.spacing.md
                    Layout.topMargin: theme.spacing.md

                    Text {
                        text: "Align To"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textMuted
                        Layout.preferredWidth: 58
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Selection", "Key Layer", "Composition"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle {
                            color: theme.colors.surface
                            border.width: 1
                            border.color: theme.colors.borderSoft
                            radius: 2
                        }
                        contentItem: Text {
                            leftPadding: 8
                            text: parent.displayText
                            font: parent.font
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: theme.colors.borderSoft
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                }

                // ALIGN section label
                Text {
                    text: "ALIGN"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                    Layout.leftMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.md
                    Layout.bottomMargin: theme.spacing.sm
                }

                // Align buttons row 1: horizontal alignment
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    // Left edge
                    AlignButton {
                        symbol: "|\u25C4"
                        tooltip: "Align Left Edges"
                    }
                    // Center H
                    AlignButton {
                        symbol: "\u25AE|"
                        tooltip: "Center Horizontally"
                    }
                    // Right edge
                    AlignButton {
                        symbol: "\u25BA|"
                        tooltip: "Align Right Edges"
                    }
                    // Top edge
                    AlignButton {
                        symbol: "\u25B4\u2014"
                        tooltip: "Align Top Edges"
                    }
                    // Center V
                    AlignButton {
                        symbol: "\u2014\u25BE"
                        tooltip: "Center Vertically"
                    }
                    // Bottom edge
                    AlignButton {
                        symbol: "\u25BE\u2014"
                        tooltip: "Align Bottom Edges"
                    }
                }

                // DISTRIBUTE section label
                Text {
                    text: "DISTRIBUTE"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                    Layout.leftMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.md
                    Layout.bottomMargin: theme.spacing.sm
                }

                // Distribute buttons
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    AlignButton {
                        symbol: "|\u2194|"
                        tooltip: "Distribute Horizontally"
                    }
                    AlignButton {
                        symbol: "|\u2195|"
                        tooltip: "Distribute Vertically"
                    }
                    AlignButton {
                        symbol: "\u21C6\u2502"
                        tooltip: "Equal Horizontal Spacing"
                    }
                    AlignButton {
                        symbol: "\u2195\u2500"
                        tooltip: "Equal Vertical Spacing"
                    }
                    Item { Layout.fillWidth: true }
                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true; height: theme.spacing.md }
            }
        }
    }

    // Inline component for align buttons
    component AlignButton: Rectangle {
        property string symbol: ""
        property string tooltip: ""

        width: 36
        height: 36
        color: alignMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
        border.width: 1
        border.color: theme.colors.borderSoft
        radius: 2

        Text {
            anchors.centerIn: parent
            text: parent.symbol
            font.pixelSize: 11
            color: theme.colors.textPrimary
        }

        ToolTip.visible: alignMa.containsMouse && parent.tooltip !== ""
        ToolTip.text: parent.tooltip
        ToolTip.delay: 600

        MouseArea {
            id: alignMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
