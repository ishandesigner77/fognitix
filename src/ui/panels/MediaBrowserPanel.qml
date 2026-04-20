import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property int filterIndex: 0
    property string currentPath: "C:/Users/User/Videos"

    readonly property var filterTabs: ["All", "Video", "Audio", "Images"]

    readonly property var sampleFiles: [
        { name: "Interview_Scene01.mp4", date: "2026-04-15", size: "1.2 GB",  type: "Video",  ext: "mp4" },
        { name: "BG_Music_Track.wav",    date: "2026-04-14", size: "48 MB",   type: "Audio",  ext: "wav" },
        { name: "Logo_Overlay.png",      date: "2026-04-14", size: "2.1 MB",  type: "Images", ext: "png" },
        { name: "Drone_Flyover.mp4",     date: "2026-04-13", size: "3.4 GB",  type: "Video",  ext: "mp4" },
        { name: "Ambience_Loop.wav",     date: "2026-04-13", size: "18 MB",   type: "Audio",  ext: "wav" },
        { name: "Thumbnail_v2.jpg",      date: "2026-04-12", size: "620 KB",  type: "Images", ext: "jpg" },
        { name: "Interview_Scene02.mp4", date: "2026-04-12", size: "980 MB",  type: "Video",  ext: "mp4" },
        { name: "SFX_Door_Creak.wav",    date: "2026-04-11", size: "1.4 MB",  type: "Audio",  ext: "wav" },
        { name: "Texture_Grunge.png",    date: "2026-04-10", size: "8.8 MB",  type: "Images", ext: "png" },
        { name: "Timelapse_City.mp4",    date: "2026-04-10", size: "560 MB",  type: "Video",  ext: "mp4" }
    ]

    property var filteredFiles: {
        if (filterIndex === 0) return sampleFiles
        var t = filterTabs[filterIndex]
        return sampleFiles.filter(function(f) { return f.type === t })
    }

    property var selectedIndices: []

    function extColor(ext) {
        if (ext === "mp4" || ext === "mov") return "#403a30"
        if (ext === "wav" || ext === "mp3") return "#7a8470"
        if (ext === "png" || ext === "jpg") return "#403a30"
        return "#555555"
    }

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
                text: "MEDIA BROWSER"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        // Path bar
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.xs
                anchors.rightMargin: theme.spacing.xs
                spacing: theme.spacing.xs

                Rectangle {
                    width: 24; height: 24; radius: 2
                    color: backMa.containsMouse ? theme.colors.surfaceHover : "transparent"
                    border.width: 1; border.color: backMa.containsMouse ? theme.colors.borderSoft : "transparent"

                    Text { anchors.centerIn: parent; text: "\u2190"; font.pixelSize: 13; color: theme.colors.textPrimary }
                    MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: theme.colors.surfaceRaised
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6; anchors.rightMargin: 6
                        spacing: 4

                        Text { text: "\u25A3"; font.pixelSize: 10; color: theme.colors.textDim }

                        TextInput {
                            Layout.fillWidth: true
                            text: currentPath
                            font.pixelSize: theme.typography.small
                            font.family: "monospace"
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            selectByMouse: true
                        }
                    }
                }
            }
        }

        // Main split: quick access + file list
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Quick access sidebar
            Rectangle {
                Layout.preferredWidth: 110
                Layout.fillHeight: true
                color: theme.colors.surface
                border.width: 1
                border.color: theme.colors.borderSoft

                Column {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: theme.spacing.xs

                    Text {
                        leftPadding: theme.spacing.sm
                        text: "QUICK ACCESS"
                        font.pixelSize: 9
                        font.letterSpacing: 0.5
                        color: theme.colors.textDim
                        height: 20
                        verticalAlignment: Text.AlignVCenter
                    }

                    Repeater {
                        model: [
                            { label: "Desktop",   sym: "\u25A1" },
                            { label: "Documents", sym: "\u25A1" },
                            { label: "Downloads", sym: "\u25A1" },
                            { label: "Recent",    sym: "\u25D4" }
                        ]

                        delegate: Rectangle {
                            width: parent.width; height: 24
                            color: qaMa.containsMouse ? theme.colors.surfaceHover : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: theme.spacing.sm
                                anchors.rightMargin: theme.spacing.xs
                                spacing: 5

                                Text { text: modelData.sym; font.pixelSize: 10; color: theme.colors.textDim }
                                Text {
                                    text: modelData.label
                                    font.pixelSize: theme.typography.small
                                    color: theme.colors.textPrimary
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea { id: qaMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                        }
                    }
                }
            }

            Rectangle { width: 1; Layout.fillHeight: true; color: theme.colors.borderSoft }

            // File list
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Column header
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: theme.colors.surface
                    border.width: 1
                    border.color: theme.colors.borderSoft

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacing.sm
                        anchors.rightMargin: theme.spacing.sm
                        spacing: 0

                        Text { text: "Name"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.fillWidth: true }
                        Text { text: "Date"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 80 }
                        Text { text: "Size"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 60 }
                        Text { text: "Type"; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 46 }
                    }
                }

                // File rows
                ListView {
                    id: fileList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: filteredFiles
                    clip: true

                    delegate: Rectangle {
                        width: fileList.width
                        height: 26
                        color: selectedIndices.indexOf(index) !== -1
                            ? Qt.rgba(theme.colors.accent.r, theme.colors.accent.g, theme.colors.accent.b, 0.2)
                            : (fileMa.containsMouse ? theme.colors.surfaceHover : (index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.015)))
                        border.width: 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: theme.spacing.sm
                            anchors.rightMargin: theme.spacing.sm
                            spacing: 0

                            // Ext badge
                            Rectangle {
                                width: 28; height: 16; radius: 2
                                color: extColor(modelData.ext)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.ext.toUpperCase()
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: "#ccddcc"
                                }
                            }

                            Item { width: 6 }

                            Text {
                                text: modelData.name
                                font.pixelSize: theme.typography.small
                                color: theme.colors.textPrimary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text { text: modelData.date; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 80 }
                            Text { text: modelData.size; font.pixelSize: theme.typography.small; color: theme.colors.textMuted; Layout.preferredWidth: 60 }
                            Text { text: modelData.type; font.pixelSize: theme.typography.small; color: theme.colors.textDim; Layout.preferredWidth: 46 }
                        }

                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSoft; opacity: 0.5 }

                        MouseArea {
                            id: fileMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var i = selectedIndices.indexOf(index)
                                var arr = selectedIndices.slice()
                                if (i === -1) arr.push(index)
                                else arr.splice(i, 1)
                                selectedIndices = arr
                            }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

        // Bottom: filter tabs + import button
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: theme.colors.surface

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.sm
                anchors.rightMargin: theme.spacing.sm
                spacing: 3

                Repeater {
                    model: filterTabs
                    delegate: Rectangle {
                        implicitWidth: ftLbl.implicitWidth + 12; height: 24; radius: 2
                        color: filterIndex === index ? theme.colors.accent : (ftMa.containsMouse ? theme.colors.surfaceHover : "transparent")
                        border.width: 1; border.color: filterIndex === index ? theme.colors.accent : theme.colors.borderSoft

                        Text { id: ftLbl; anchors.centerIn: parent; text: modelData; font.pixelSize: theme.typography.small; color: filterIndex === index ? theme.colors.textOnAccent : theme.colors.textPrimary }
                        MouseArea { id: ftMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: filterIndex = index }
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: importLbl.implicitWidth + theme.spacing.md * 2; height: 26
                    color: importMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                    radius: 2

                    Text { id: importLbl; anchors.centerIn: parent; text: "Import Selected"; font.pixelSize: theme.typography.small; font.weight: Font.Medium; color: theme.colors.textOnAccent }
                    MouseArea { id: importMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }
            }
        }
    }
}
