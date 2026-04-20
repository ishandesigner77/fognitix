import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property var footageProps: [
        { key: "Name",         value: "\u2014" },
        { key: "Duration",     value: "\u2014" },
        { key: "In Point",     value: "\u2014" },
        { key: "Out Point",    value: "\u2014" },
        { key: "Frame Rate",   value: "\u2014" },
        { key: "Resolution",   value: "\u2014" },
        { key: "Pixel Aspect", value: "\u2014" },
        { key: "Field Order",  value: "\u2014" },
        { key: "Alpha",        value: "\u2014" },
        { key: "File Path",    value: "\u2014" }
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
                text: "FOOTAGE INFO"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        // Thumbnail area
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#111111"
            border.width: 1
            border.color: theme.colors.borderSoft

            Text {
                anchors.centerIn: parent
                text: "No clip selected"
                font.pixelSize: theme.typography.small
                color: theme.colors.textDim
            }

            // Timecode overlay bar
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 18
                color: Qt.rgba(0, 0, 0, 0.6)

                Text {
                    anchors.centerIn: parent
                    text: "00:00:00:00"
                    font.pixelSize: 10
                    font.family: "monospace"
                    color: "#aaaaaa"
                }
            }
        }

        // Property list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ListView {
                anchors.fill: parent
                model: footageProps

                delegate: Item {
                    width: ListView.view.width
                    height: 26

                    Rectangle {
                        anchors.fill: parent
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.02)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacing.md
                        anchors.rightMargin: theme.spacing.md
                        spacing: theme.spacing.sm

                        Text {
                            text: modelData.key
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textMuted
                            Layout.preferredWidth: 100
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.value
                            font.pixelSize: theme.typography.small
                            color: theme.colors.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width; height: 1
                        color: theme.colors.borderSoft
                    }
                }
            }
        }

        // Bottom buttons
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.colors.borderSoft
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: theme.spacing.sm
            spacing: theme.spacing.sm

            FootageButton { text: "Relink Media..." }
            FootageButton { text: "Replace Footage..." }
            Item { Layout.fillWidth: true }
        }
    }

    component FootageButton: Rectangle {
        property string text: ""

        implicitHeight: 28
        implicitWidth: btnText.implicitWidth + theme.spacing.md * 2
        color: btnMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
        border.width: 1; border.color: theme.colors.borderSoft
        radius: 2

        Text {
            id: btnText
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: theme.typography.small
            color: theme.colors.textPrimary
        }

        MouseArea { id: btnMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
    }
}
