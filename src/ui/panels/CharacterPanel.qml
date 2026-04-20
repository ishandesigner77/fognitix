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
                text: "CHARACTER"
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

                // Font family
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text {
                        text: "Font Family"
                        font.pixelSize: theme.typography.micro
                        color: theme.colors.textMuted
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Inter", "Roboto", "Open Sans", "Montserrat", "Source Sans Pro", "Arial", "Helvetica Neue"]
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

                // Font size + style buttons
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.sm

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Size"
                            font.pixelSize: theme.typography.micro
                            color: theme.colors.textMuted
                        }

                        Rectangle {
                            width: 68
                            height: 28
                            color: theme.colors.surface
                            border.width: 1
                            border.color: theme.colors.borderSoft
                            radius: 2

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                TextInput {
                                    Layout.fillWidth: true
                                    text: "72"
                                    font.pixelSize: theme.typography.small
                                    color: theme.colors.textPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    selectByMouse: true
                                }

                                Rectangle {
                                    width: 1
                                    height: parent.height
                                    color: theme.colors.borderSoft
                                }

                                ColumnLayout {
                                    width: 14
                                    spacing: 0

                                    Text {
                                        text: "\u25B4"
                                        font.pixelSize: 8
                                        color: theme.colors.textMuted
                                        Layout.alignment: Qt.AlignHCenter
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                                    }
                                    Text {
                                        text: "\u25BE"
                                        font.pixelSize: 8
                                        color: theme.colors.textMuted
                                        Layout.alignment: Qt.AlignHCenter
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                                    }
                                }
                            }
                        }
                    }

                    Item { width: theme.spacing.xs }

                    // Style buttons B I U S
                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Style"
                            font.pixelSize: theme.typography.micro
                            color: theme.colors.textMuted
                        }

                        RowLayout {
                            spacing: 3

                            Repeater {
                                model: [
                                    { label: "B", bold: true },
                                    { label: "I", italic: true },
                                    { label: "U", underline: true },
                                    { label: "S", strikeout: true }
                                ]

                                delegate: Rectangle {
                                    width: 28
                                    height: 28
                                    color: styleToggle ? theme.colors.accent : theme.colors.surface
                                    border.width: 1
                                    border.color: styleToggle ? theme.colors.accent : theme.colors.borderSoft
                                    radius: 2

                                    property bool styleToggle: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: theme.typography.small
                                        font.bold: modelData.bold ?? false
                                        font.italic: modelData.italic ?? false
                                        font.underline: modelData.underline ?? false
                                        font.strikeout: modelData.strikeout ?? false
                                        color: styleToggle ? theme.colors.textOnAccent : theme.colors.textPrimary
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: parent.styleToggle = !parent.styleToggle
                                    }
                                }
                            }
                        }
                    }
                }

                // Separator
                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Fill / Stroke colors
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: theme.spacing.md

                    ColumnLayout {
                        spacing: 4

                        Text { text: "Fill"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }
                        Rectangle {
                            width: 36; height: 24
                            color: "#ffffff"
                            border.width: 1; border.color: theme.colors.borderSoft
                            radius: 2
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Text { text: "Stroke"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }
                        Rectangle {
                            width: 36; height: 24
                            color: "transparent"
                            border.width: 1; border.color: theme.colors.borderSoft
                            radius: 2

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 3
                                color: "#000000"
                                radius: 1
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text { text: "Stroke W"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 24
                            color: theme.colors.surface
                            border.width: 1; border.color: theme.colors.borderSoft
                            radius: 2

                            TextInput {
                                anchors.fill: parent
                                anchors.margins: 6
                                text: "0"
                                font.pixelSize: theme.typography.small
                                color: theme.colors.textPrimary
                                verticalAlignment: Text.AlignVCenter
                                selectByMouse: true
                            }
                        }
                    }
                }

                // Separator
                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Tracking slider
                CharSliderRow { label: "Tracking"; min: -200; max: 200; value: 0; unit: "" }

                // Leading slider
                CharSliderRow { label: "Leading"; min: 0; max: 200; value: 100; unit: "%" }

                // Baseline shift
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    Text {
                        text: "Baseline Shift"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textMuted
                        Layout.preferredWidth: 90
                    }

                    Rectangle {
                        Layout.preferredWidth: 64
                        height: 24
                        color: theme.colors.surface
                        border.width: 1; border.color: theme.colors.borderSoft
                        radius: 2

                        TextInput {
                            anchors.fill: parent; anchors.margins: 6
                            text: "0"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            selectByMouse: true
                        }
                    }

                    Text {
                        text: "px"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textMuted
                    }
                    Item { Layout.fillWidth: true }
                }

                // Kerning checkbox
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    CheckBox {
                        checked: true
                        text: "Auto Kerning"
                        font.pixelSize: theme.typography.small

                        contentItem: Text {
                            leftPadding: parent.indicator.width + 6
                            text: parent.text
                            font: parent.font
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                // Reset button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    Layout.topMargin: theme.spacing.sm
                    Layout.bottomMargin: theme.spacing.md
                    height: 28
                    color: resetMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                    border.width: 1
                    border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Reset to Defaults"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textPrimary
                    }

                    MouseArea {
                        id: resetMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    component CharSliderRow: RowLayout {
        property string label: ""
        property real min: 0
        property real max: 100
        property real value: 50
        property string unit: ""

        Layout.fillWidth: true
        Layout.leftMargin: theme.spacing.md
        Layout.rightMargin: theme.spacing.md

        Text {
            text: label
            font.pixelSize: theme.typography.small
            color: theme.colors.textMuted
            Layout.preferredWidth: 90
        }

        Slider {
            Layout.fillWidth: true
            from: min
            to: max
            value: parent.value
            height: 24

            background: Rectangle {
                x: parent.leftPadding
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: parent.availableWidth
                height: 2
                color: theme.colors.borderSoft
                radius: 1

                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    color: theme.colors.accent
                    radius: 1
                }
            }

            handle: Rectangle {
                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: 12; height: 12
                radius: 6
                color: theme.colors.accent
            }
        }

        Text {
            text: Math.round(parent.value) + parent.unit
            font.pixelSize: theme.typography.small
            color: theme.colors.textPrimary
            Layout.preferredWidth: 36
            horizontalAlignment: Text.AlignRight
        }
    }
}
