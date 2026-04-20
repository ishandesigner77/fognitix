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
                text: "SMOOTHER"
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

                // Apply To
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Apply To"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Spatial Path", "Temporal Graph"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                // Tolerance slider
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    RowLayout {
                        Text { text: "Tolerance"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: toleranceLabel
                            text: "5"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        id: toleranceSlider
                        from: 0; to: 100; value: 5
                        height: 24

                        onValueChanged: toleranceLabel.text = Math.round(value)

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

                    RowLayout {
                        Text { text: "0"; font.pixelSize: theme.typography.micro; color: theme.colors.textDim }
                        Item { Layout.fillWidth: true }
                        Text { text: "100"; font.pixelSize: theme.typography.micro; color: theme.colors.textDim }
                    }
                }

                // Handles dropdown
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Handles"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Auto Bezier", "Continuous", "Linear"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                // Description
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: descText.implicitHeight + theme.spacing.md
                    color: theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        id: descText
                        anchors {
                            left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                            leftMargin: theme.spacing.sm; rightMargin: theme.spacing.sm
                        }
                        text: "Smoothes keyframe timing. Select keyframes before applying."
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textDim
                        wrapMode: Text.WordWrap
                    }
                }

                // Apply button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 32
                    color: applyMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Apply"
                        font.pixelSize: theme.typography.small
                        font.weight: Font.Medium
                        color: theme.colors.textOnAccent
                    }

                    MouseArea {
                        id: applyMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
