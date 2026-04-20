import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property bool analyzing: false
    property real analysisProgress: 0

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
                text: "CONTENT-AWARE FILL"
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

                Item { height: theme.spacing.xs }

                // Generate Fill Layer button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 34
                    color: genMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.12) : theme.colors.accent
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Generate Fill Layer"
                        font.pixelSize: theme.typography.body
                        font.weight: Font.Medium
                        color: theme.colors.textOnAccent
                    }

                    MouseArea { id: genMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Fill Method
                LabeledCombo {
                    label: "Fill Method"
                    model: ["Object", "Edge Blend", "Surface"]
                }

                // Alpha Expansion
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    RowLayout {
                        Text { text: "Alpha Expansion"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: alphaLabel
                            text: "0"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100; value: 0
                        height: 24
                        onValueChanged: alphaLabel.text = Math.round(value)
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

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // FILL SETTINGS section
                Text {
                    text: "FILL SETTINGS"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                    Layout.leftMargin: theme.spacing.md
                }

                Repeater {
                    model: [
                        { text: "Create Reference Frame", checked: true },
                        { text: "Export Fill Layer",       checked: true },
                        { text: "Collaboration",           checked: false }
                    ]

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: theme.spacing.md
                        Layout.rightMargin: theme.spacing.md

                        CheckBox {
                            id: fillCb
                            checked: modelData.checked
                            text: modelData.text
                            font.pixelSize: theme.typography.small
                            contentItem: Text {
                                leftPadding: fillCb.indicator.width + 6
                                text: fillCb.text; font: fillCb.font
                                color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Output To
                LabeledCombo {
                    label: "Output To"
                    model: ["New Layer", "Replace Source"]
                }

                // Analyze button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 30
                    color: analyzeMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: analyzing ? "Stop" : "Analyze"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textPrimary
                    }

                    MouseArea {
                        id: analyzeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            analyzing = !analyzing
                            if (analyzing) {
                                fakeProgress.start()
                            } else {
                                fakeProgress.stop()
                                analysisProgress = 0
                            }
                        }
                    }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 6
                    visible: analyzing
                    color: theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 3

                    Rectangle {
                        width: parent.width * analysisProgress
                        height: parent.height
                        color: theme.colors.accent
                        radius: 3
                    }
                }

                Item { height: theme.spacing.md }
            }
        }
    }

    Timer {
        id: fakeProgress
        interval: 80
        repeat: true
        onTriggered: {
            analysisProgress = Math.min(1.0, analysisProgress + 0.015)
            if (analysisProgress >= 1.0) {
                stop()
                analyzing = false
            }
        }
    }

    component LabeledCombo: RowLayout {
        property string label: ""
        property var model: []

        Layout.fillWidth: true
        Layout.leftMargin: theme.spacing.md
        Layout.rightMargin: theme.spacing.md
        spacing: theme.spacing.sm

        Text {
            text: parent.label
            font.pixelSize: theme.typography.small
            color: theme.colors.textMuted
            Layout.preferredWidth: 100
        }

        ComboBox {
            Layout.fillWidth: true
            model: parent.model
            font.pixelSize: theme.typography.small
            background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
            contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
        }
    }
}
