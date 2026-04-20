import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property var metadataFields: [
        { key: "File Name",    value: "\u2014" },
        { key: "File Type",    value: "\u2014" },
        { key: "File Size",    value: "\u2014" },
        { key: "Duration",     value: "\u2014" },
        { key: "Frame Rate",   value: "\u2014" },
        { key: "Video Codec",  value: "\u2014" },
        { key: "Audio Codec",  value: "\u2014" },
        { key: "Resolution",   value: "\u2014" },
        { key: "Bit Rate",     value: "\u2014" },
        { key: "Created",      value: "\u2014" },
        { key: "Modified",     value: "\u2014" },
        { key: "Color Space",  value: "\u2014" },
        { key: "Scene",        value: "\u2014" },
        { key: "Shot",         value: "\u2014" },
        { key: "Reel",         value: "\u2014" },
        { key: "Camera",       value: "\u2014" },
        { key: "Lens",         value: "\u2014" },
        { key: "ISO",          value: "\u2014" },
        { key: "Aperture",     value: "\u2014" },
        { key: "Shutter",      value: "\u2014" }
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
                anchors.leftMargin: theme.spacing.s3
                text: "METADATA"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        // Search field
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.panelAlt
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.s2
                anchors.rightMargin: theme.spacing.s2
                spacing: theme.spacing.s1

                Text {
                    text: "\u2315"
                    font.pixelSize: 14
                    color: theme.colors.textDisabled
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search metadata…")
                    font.pixelSize: theme.typography.metadata
                    color: theme.colors.textPrimary
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    background: Item {}
                }

                Rectangle {
                    visible: searchInput.text.length > 0
                    width: 16; height: 16; radius: 8
                    color: clearMa.containsMouse ? theme.colors.surfacePeak : "transparent"

                    Text { anchors.centerIn: parent; text: "\u2715"; font.pixelSize: 9; color: theme.colors.textMuted }
                    MouseArea { id: clearMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: searchInput.text = "" }
                }
            }
        }

        // Metadata list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ListView {
                id: metaList
                anchors.fill: parent
                model: {
                    var q = searchInput.text.toLowerCase()
                    if (q === "") return metadataFields
                    return metadataFields.filter(function(f) {
                        return f.key.toLowerCase().indexOf(q) !== -1
                    })
                }

                delegate: Item {
                    width: metaList.width
                    height: 28

                    Rectangle {
                        anchors.fill: parent
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.02)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacing.s3
                        anchors.rightMargin: theme.spacing.s3
                        spacing: theme.spacing.s2

                        Text {
                            text: modelData.key
                            font.pixelSize: theme.typography.metadata
                            color: theme.colors.textMuted
                            Layout.preferredWidth: 110
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.value
                            font.pixelSize: theme.typography.metadata
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
    }
}
