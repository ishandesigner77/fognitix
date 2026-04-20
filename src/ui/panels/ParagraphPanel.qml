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
                text: "PARAGRAPH"
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

                // Paragraph style combo
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Paragraph Style"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Normal", "Heading 1", "Heading 2", "Heading 3", "Caption", "Body Text", "Subtitle"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Alignment buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Alignment"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: 3

                        property int selectedAlign: 0

                        Repeater {
                            model: [
                                { sym: "\u2630", tip: "Align Left" },
                                { sym: "\u2261", tip: "Center" },
                                { sym: "\u2630", tip: "Align Right" },
                                { sym: "\u2630", tip: "Justify" },
                                { sym: "\u2263", tip: "Justify Last Left" }
                            ]

                            delegate: Rectangle {
                                width: 32; height: 28
                                radius: 2
                                color: index === 0 ? theme.colors.accent : (alignMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface)
                                border.width: 1
                                border.color: index === 0 ? theme.colors.accent : theme.colors.borderSoft

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.sym
                                    font.pixelSize: 11
                                    color: index === 0 ? theme.colors.textOnAccent : theme.colors.textPrimary
                                }

                                ToolTip.visible: alignMa.containsMouse
                                ToolTip.text: modelData.tip
                                ToolTip.delay: 600

                                MouseArea { id: alignMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Indent
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Indent"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: theme.spacing.md

                        RowLayout {
                            spacing: 6
                            Text { text: "Left"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 28 }
                            SpinnerRect { value: 0 }
                            Text { text: "px"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        }

                        RowLayout {
                            spacing: 6
                            Text { text: "Right"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 34 }
                            SpinnerRect { value: 0 }
                            Text { text: "px"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Space before / after
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Spacing"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: theme.spacing.md

                        RowLayout {
                            spacing: 6
                            Text { text: "Before"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 38 }
                            SpinnerRect { value: 0 }
                            Text { text: "px"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        }

                        RowLayout {
                            spacing: 6
                            Text { text: "After"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 34 }
                            SpinnerRect { value: 0 }
                            Text { text: "px"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Text direction
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Text Direction"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: 3

                        property int selected: 0

                        Rectangle {
                            width: 52; height: 28
                            radius: 2
                            color: parent.selected === 0 ? theme.colors.accent : (ltrMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface)
                            border.width: 1
                            border.color: parent.selected === 0 ? theme.colors.accent : theme.colors.borderSoft

                            Text {
                                anchors.centerIn: parent
                                text: "LTR"
                                font.pixelSize: theme.typography.small
                                color: parent.parent.selected === 0 ? theme.colors.textOnAccent : theme.colors.textPrimary
                            }
                            MouseArea {
                                id: ltrMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.parent.selected = 0
                            }
                        }

                        Rectangle {
                            width: 52; height: 28
                            radius: 2
                            color: parent.selected === 1 ? theme.colors.accent : (rtlMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface)
                            border.width: 1
                            border.color: parent.selected === 1 ? theme.colors.accent : theme.colors.borderSoft

                            Text {
                                anchors.centerIn: parent
                                text: "RTL"
                                font.pixelSize: theme.typography.small
                                color: parent.parent.selected === 1 ? theme.colors.textOnAccent : theme.colors.textPrimary
                            }
                            MouseArea {
                                id: rtlMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.parent.selected = 1
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Hanging punctuation
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    CheckBox {
                        id: hangingPuncCb
                        text: "Hanging Punctuation"
                        font.pixelSize: theme.typography.small
                        contentItem: Text {
                            leftPadding: hangingPuncCb.indicator.width + 6
                            text: hangingPuncCb.text
                            font: hangingPuncCb.font
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Item { height: theme.spacing.md }
            }
        }
    }

    component SpinnerRect: Rectangle {
        property int value: 0
        width: 54; height: 24
        color: theme.colors.surface
        border.width: 1; border.color: theme.colors.borderSoft
        radius: 2

        TextInput {
            anchors.fill: parent; anchors.margins: 6
            text: parent.value.toString()
            font.pixelSize: theme.typography.small
            color: theme.colors.textPrimary
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            selectByMouse: true
        }
    }
}
