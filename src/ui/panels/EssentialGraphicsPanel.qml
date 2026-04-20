import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property int currentTab: 0

    readonly property var templates: [
        { name: "Lower Third",  color: "#2d4a6a" },
        { name: "Title Card",   color: "#4a2d6a" },
        { name: "End Screen",   color: "#2d6a4a" },
        { name: "Ticker",       color: "#6a4a2d" },
        { name: "Countdown",    color: "#6a2d4a" },
        { name: "Callout",      color: "#2d6a6a" },
        { name: "Subtitle",     color: "#4a4a2d" },
        { name: "Logo Bug",     color: "#4a6a2d" }
    ]

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
                text: "ESSENTIAL GRAPHICS"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        // Search
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.sm
                anchors.rightMargin: theme.spacing.sm
                spacing: theme.spacing.xs

                Text { text: "\u2315"; font.pixelSize: 14; color: theme.colors.textDim }

                TextInput {
                    Layout.fillWidth: true
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true

                    Text {
                        visible: !parent.text && !parent.activeFocus
                        text: "Search templates..."
                        font: parent.font; color: theme.colors.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Tab bar
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ["Browse", "My Templates"]

                    delegate: Rectangle {
                        Layout.preferredWidth: 110; height: parent.height
                        color: currentTab === index ? theme.colors.surfaceRaised : (egTabMa.containsMouse ? theme.colors.surfaceHover : "transparent")

                        Rectangle {
                            visible: currentTab === index
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 2; color: theme.colors.accent
                        }

                        Text {
                            anchors.centerIn: parent; text: modelData
                            font.pixelSize: theme.typography.small
                            color: currentTab === index ? theme.colors.textPrimary : theme.colors.textMuted
                        }

                        MouseArea { id: egTabMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: currentTab = index }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Template grid
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: theme.spacing.sm
                rowSpacing: theme.spacing.sm
                anchors.margins: theme.spacing.sm

                Repeater {
                    model: templates

                    delegate: Rectangle {
                        id: cardRect
                        Layout.fillWidth: true
                        height: 90
                        color: theme.colors.surface
                        border.width: 1
                        border.color: cardHover.hovered ? theme.colors.accent : theme.colors.borderSoft
                        radius: 3
                        clip: true

                        HoverHandler { id: cardHover }

                        // Color accent stripe
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left; anchors.right: parent.right
                            height: 4
                            color: modelData.color
                            radius: 2
                        }

                        Text {
                            anchors.top: parent.top
                            anchors.topMargin: 16
                            anchors.left: parent.left; anchors.right: parent.right
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData.name
                            font.pixelSize: theme.typography.small
                            font.weight: Font.Medium
                            color: theme.colors.textPrimary
                            elide: Text.ElideRight
                            leftPadding: 6; rightPadding: 6
                        }

                        // Apply button - visible on hover
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 60; height: 22
                            visible: cardHover.hovered
                            color: applyBtnMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                            radius: 2

                            Text { anchors.centerIn: parent; text: "Apply"; font.pixelSize: theme.typography.small; color: theme.colors.textOnAccent }
                            MouseArea { id: applyBtnMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

        // Bottom: install from file
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: theme.colors.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: theme.spacing.sm

                Rectangle {
                    implicitWidth: installLbl.implicitWidth + theme.spacing.md * 2
                    height: 26
                    color: installMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text {
                        id: installLbl
                        anchors.centerIn: parent
                        text: "Install from file..."
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textPrimary
                    }
                    MouseArea { id: installMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
