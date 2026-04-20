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
                text: "MOTION TRACKER"
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
                spacing: 0

                // ---- ANALYZE section ----
                SectionHeader { label: "ANALYZE" }

                // Transport row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.sm
                    Layout.bottomMargin: theme.spacing.sm
                    spacing: theme.spacing.sm

                    Repeater {
                        model: [
                            { sym: "\u23EE", tip: "Go to First Frame" },
                            { sym: "\u23EA", tip: "Analyze Backward" },
                            { sym: "\u23E9", tip: "Analyze Forward" },
                            { sym: "\u23ED", tip: "Go to Last Frame" }
                        ]

                        delegate: Rectangle {
                            width: 38; height: 32
                            radius: 2
                            color: transMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                            border.width: 1; border.color: theme.colors.borderSoft

                            Text {
                                anchors.centerIn: parent
                                text: modelData.sym
                                font.pixelSize: 14
                                color: theme.colors.textPrimary
                            }

                            ToolTip.visible: transMa.containsMouse
                            ToolTip.text: modelData.tip
                            ToolTip.delay: 600

                            MouseArea { id: transMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Method combo
                PropRow {
                    label: "Method"
                    content: ComboBox {
                        Layout.fillWidth: true
                        model: ["Position", "Position & Scale", "Position & Rotation", "Perspective"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                // Track type checkboxes
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.xs
                    Layout.bottomMargin: theme.spacing.xs
                    spacing: 4

                    Text { text: "Track"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: theme.spacing.md

                        Repeater {
                            model: ["Position", "Rotation", "Scale"]
                            delegate: CheckBox {
                                checked: modelData === "Position"
                                text: modelData
                                font.pixelSize: theme.typography.small
                                contentItem: Text {
                                    leftPadding: parent.indicator.width + 4
                                    text: parent.text; font: parent.font
                                    color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                SectionSep {}

                // Search region sliders
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.sm
                    spacing: 4

                    Text { text: "Search Region"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    TrackerSlider { label: "W"; value: 40 }
                    TrackerSlider { label: "H"; value: 40 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.sm
                    spacing: 4

                    Text { text: "Feature Size"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    TrackerSlider { label: "W"; value: 15 }
                    TrackerSlider { label: "H"; value: 15 }
                }

                SectionSep {}

                // ---- STABILIZE section ----
                SectionHeader { label: "STABILIZE" }

                PropRow {
                    label: "Smooth"
                    content: RowLayout {
                        Layout.fillWidth: true
                        spacing: theme.spacing.sm

                        Slider {
                            Layout.fillWidth: true
                            from: 0; to: 100; value: 50
                            height: 24
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
                        Text { text: "50%"; font.pixelSize: theme.typography.small; color: theme.colors.textPrimary; Layout.preferredWidth: 32; horizontalAlignment: Text.AlignRight }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.sm
                    height: 28
                    color: applyStabMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                    radius: 2

                    Text { anchors.centerIn: parent; text: "Apply Stabilization"; font.pixelSize: theme.typography.small; color: theme.colors.textOnAccent }
                    MouseArea { id: applyStabMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                SectionSep {}

                // ---- WARP STABILIZER section ----
                SectionHeader { label: "WARP STABILIZER" }

                PropRow {
                    label: "Mode"
                    content: ComboBox {
                        Layout.fillWidth: true
                        model: ["Smooth Motion", "No Motion"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                PropRow {
                    label: "Smoothness"
                    content: RowLayout {
                        Layout.fillWidth: true
                        spacing: theme.spacing.sm

                        Slider {
                            Layout.fillWidth: true
                            from: 0; to: 100; value: 50
                            height: 24
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
                        Text { text: "50%"; font.pixelSize: theme.typography.small; color: theme.colors.textPrimary; Layout.preferredWidth: 32; horizontalAlignment: Text.AlignRight }
                    }
                }

                Item { height: theme.spacing.md }
            }
        }
    }

    component SectionHeader: Rectangle {
        property string label: ""

        Layout.fillWidth: true
        height: 26
        color: theme.colors.surface
        border.width: 1
        border.color: theme.colors.borderSoft

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: theme.spacing.md
            text: parent.label
            font.pixelSize: theme.typography.micro
            font.letterSpacing: 0.6
            font.weight: Font.Medium
            color: theme.colors.textMuted
        }
    }

    component SectionSep: Rectangle {
        Layout.fillWidth: true
        height: 1
        color: theme.colors.borderSoft
    }

    component PropRow: RowLayout {
        property string label: ""
        default property alias content: contentContainer.data

        Layout.fillWidth: true
        Layout.leftMargin: theme.spacing.md
        Layout.rightMargin: theme.spacing.md
        Layout.topMargin: theme.spacing.xs
        spacing: theme.spacing.sm

        Text {
            text: parent.label
            font.pixelSize: theme.typography.small
            color: theme.colors.textMuted
            Layout.preferredWidth: 72
        }

        Item {
            id: contentContainer
            Layout.fillWidth: true
            implicitHeight: 28
        }
    }

    component TrackerSlider: RowLayout {
        property string label: ""
        property real value: 50

        Layout.fillWidth: true
        spacing: theme.spacing.sm

        Text { text: parent.label; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 12 }

        Slider {
            Layout.fillWidth: true
            from: 0; to: 200; value: parent.value
            height: 20

            background: Rectangle {
                x: parent.leftPadding; y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: parent.availableWidth; height: 2; color: theme.colors.borderSoft; radius: 1
                Rectangle { width: parent.parent.visualPosition * parent.width; height: 2; color: theme.colors.accent; radius: 1 }
            }
            handle: Rectangle {
                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: 10; height: 10; radius: 5; color: theme.colors.accent
            }
        }

        Text {
            text: Math.round(parent.value)
            font.pixelSize: theme.typography.small
            color: theme.colors.textPrimary
            Layout.preferredWidth: 28
            horizontalAlignment: Text.AlignRight
        }
    }
}
