import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    // Bindings would connect to appState / mainWindow in production
    // Shown as placeholders with monospace values

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
                text: "INFO"
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

                // COMPOSITION INFO
                InfoSectionHeader { label: "COMPOSITION INFO" }

                InfoRow { key: "Name";             value: "Main Composition" }
                InfoRow { key: "Duration";         value: "00:00:30:00";  mono: true }
                InfoRow { key: "Frame Rate";       value: "29.97 fps";    mono: true }
                InfoRow { key: "Resolution";       value: "1920 x 1080";  mono: true }
                InfoRow {
                    key: "Background"
                    value: ""
                    extra: Rectangle {
                        width: 16; height: 16; radius: 2
                        color: "#000000"
                        border.width: 1; border.color: theme.colors.borderSoft
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // PLAYBACK INFO
                InfoSectionHeader { label: "PLAYBACK INFO" }

                InfoRow { key: "Current Time";     value: "00:00:00:00";  mono: true }
                InfoRow { key: "Work Area Start";  value: "00:00:00:00";  mono: true }
                InfoRow { key: "Work Area End";    value: "00:00:30:00";  mono: true }
                InfoRow { key: "Frame Count";      value: "900";          mono: true }
                InfoRow { key: "Memory Usage";     value: "1.2 GB";       mono: true }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // PROJECT
                InfoSectionHeader { label: "PROJECT" }

                InfoRow { key: "Total Clips";      value: "\u2014" }
                InfoRow { key: "Video Tracks";     value: "\u2014" }
                InfoRow { key: "Audio Tracks";     value: "\u2014" }
                InfoRow { key: "Effects Count";    value: "\u2014" }
                InfoRow { key: "Render Status";    value: "Idle" }

                Item { height: theme.spacing.md }
            }
        }
    }

    component InfoSectionHeader: Rectangle {
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

    component InfoRow: Item {
        property string key: ""
        property string value: ""
        property bool mono: false
        default property alias extra: extraContainer.data

        Layout.fillWidth: true
        height: 26

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: theme.spacing.md
            anchors.rightMargin: theme.spacing.md
            spacing: theme.spacing.sm

            Text {
                text: key
                font.pixelSize: theme.typography.small
                color: theme.colors.textMuted
                Layout.preferredWidth: 110
                elide: Text.ElideRight
            }

            Text {
                text: value
                font.pixelSize: theme.typography.small
                font.family: mono ? "monospace" : theme.typography.fontFamily
                color: theme.colors.textPrimary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Item {
                id: extraContainer
                visible: children.length > 0
                width: children.length > 0 ? children[0].width : 0
                height: children.length > 0 ? children[0].height : 0
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: theme.colors.borderSoft
        }
    }
}
