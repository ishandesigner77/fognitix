import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property bool capturing: false

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
                text: "MOTION SKETCH"
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

                // Start Capture button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: 34
                    color: capturing
                        ? (capMa.containsMouse ? "#cc2222" : "#aa1111")
                        : (capMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.12) : theme.colors.accent)
                    radius: 2

                    // Pulse indicator when capturing
                    Rectangle {
                        visible: capturing
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8; height: 8; radius: 4
                        color: "#ff4444"

                        SequentialAnimation on opacity {
                            running: capturing
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.2; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 600 }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: capturing ? "Stop Capture" : "Start Capture"
                        font.pixelSize: theme.typography.body
                        font.weight: Font.Medium
                        color: theme.colors.textOnAccent
                    }

                    MouseArea {
                        id: capMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: capturing = !capturing
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Capture Speed slider
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    RowLayout {
                        Text { text: "Capture Speed"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: capSpeedLabel
                            text: "100%"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        id: captureSpeedSlider
                        from: 1; to: 500; value: 100
                        height: 24
                        onValueChanged: capSpeedLabel.text = Math.round(value) + "%"
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

                // Smoothing slider
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    RowLayout {
                        Text { text: "Smoothing"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: smoothLabel
                            text: "15%"
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100; value: 15
                        height: 24
                        onValueChanged: smoothLabel.text = Math.round(value) + "%"
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

                // Apply to radio buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    spacing: 4

                    Text { text: "Apply To"; font.pixelSize: theme.typography.micro; color: theme.colors.textMuted }

                    RowLayout {
                        spacing: 4
                        property int selected: 0

                        Repeater {
                            model: ["Position", "Anchor Point"]
                            delegate: Rectangle {
                                implicitWidth: applyLabel.implicitWidth + 16; height: 26; radius: 2
                                color: parent.selected === index ? theme.colors.accent : (apMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface)
                                border.width: 1; border.color: parent.selected === index ? theme.colors.accent : theme.colors.borderSoft

                                Text {
                                    id: applyLabel
                                    anchors.centerIn: parent; text: modelData
                                    font.pixelSize: theme.typography.small
                                    color: parent.parent.selected === index ? theme.colors.textOnAccent : theme.colors.textPrimary
                                }
                                MouseArea {
                                    id: apMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.selected = index
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Show Wireframe
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    CheckBox {
                        id: wireframeCb
                        text: "Show Wireframe"
                        font.pixelSize: theme.typography.small
                        contentItem: Text {
                            leftPadding: wireframeCb.indicator.width + 6
                            text: wireframeCb.text; font: wireframeCb.font
                            color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                // Background combo
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md

                    Text {
                        text: "Background"
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textMuted
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Choose...", "Black", "White", "Current Comp"]
                        font.pixelSize: theme.typography.small
                        background: Rectangle { color: theme.colors.surface; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                        contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft; Layout.leftMargin: theme.spacing.md; Layout.rightMargin: theme.spacing.md }

                // Instructions text
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md
                    Layout.rightMargin: theme.spacing.md
                    height: instrText.implicitHeight + theme.spacing.md
                    color: theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        id: instrText
                        anchors {
                            left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                            leftMargin: theme.spacing.sm; rightMargin: theme.spacing.sm
                        }
                        text: "Click Start Capture, then draw the motion path in the composition viewer."
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textDim
                        wrapMode: Text.WordWrap
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
