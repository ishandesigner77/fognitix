import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property int selectedFilter: 0
    property bool signedIn: false

    readonly property var filters: ["All", "Motion Graphics", "Color Presets", "Sound FX", "Images", "3D Assets"]

    readonly property var libraryItems: [
        { name: "Urban Pack",     type: "Motion Graphics", color: "#403a30", badge: "MG" },
        { name: "Cinematic LUT",  type: "Color Presets",   color: "#403a30", badge: "LUT" },
        { name: "Particle FX",    type: "Motion Graphics", color: "#403a30", badge: "MG" },
        { name: "Logo Reveal",    type: "Motion Graphics", color: "#403a30", badge: "MG" },
        { name: "Glitch FX",      type: "Motion Graphics", color: "#3a7a5a", badge: "VFX" },
        { name: "Sound Pack",     type: "Sound FX",        color: "#403a30", badge: "SFX" },
        { name: "3D Text",        type: "3D Assets",       color: "#7a8470", badge: "3D" },
        { name: "Color Grade",    type: "Color Presets",   color: "#403a30", badge: "LUT" }
    ]

    property var filteredItems: {
        if (selectedFilter === 0) return libraryItems
        var f = filters[selectedFilter]
        return libraryItems.filter(function(it) { return it.type === f })
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

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.md
                anchors.rightMargin: theme.spacing.sm

                Text {
                    text: "CREATIVE LIBRARY"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                }
                Item { Layout.fillWidth: true }
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
                    id: libSearch
                    Layout.fillWidth: true
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true

                    Text {
                        visible: !parent.text && !parent.activeFocus
                        text: "Search library..."
                        font: parent.font; color: theme.colors.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Filter row
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                RowLayout {
                    height: parent.height
                    spacing: 2

                    Item { width: theme.spacing.sm }

                    Repeater {
                        model: filters

                        delegate: Rectangle {
                            implicitWidth: filterLbl.implicitWidth + 12; height: 22; radius: 2
                            color: selectedFilter === index ? theme.colors.accent : (filterMa.containsMouse ? theme.colors.surfaceHover : "transparent")
                            border.width: 1; border.color: selectedFilter === index ? theme.colors.accent : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: filterLbl
                                anchors.centerIn: parent; text: modelData
                                font.pixelSize: theme.typography.small
                                color: selectedFilter === index ? theme.colors.textOnAccent : theme.colors.textMuted
                            }

                            MouseArea {
                                id: filterMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: selectedFilter = index
                            }
                        }
                    }

                    Item { width: theme.spacing.sm }
                }
            }
        }

        // Content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Signed-in: grid
            ScrollView {
                anchors.fill: parent
                visible: signedIn
                contentWidth: availableWidth

                GridLayout {
                    width: parent.width
                    columns: 3
                    columnSpacing: theme.spacing.sm
                    rowSpacing: theme.spacing.sm
                    anchors.margins: theme.spacing.sm

                    Repeater {
                        model: filteredItems

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            color: itemMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                            border.width: 1; border.color: theme.colors.borderSoft
                            radius: 3
                            clip: true

                            // Color strip at top
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left; anchors.right: parent.right
                                height: 28
                                color: modelData.color
                                radius: 3

                                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 3; color: modelData.color }

                                Text {
                                    anchors.right: parent.right; anchors.rightMargin: 4
                                    anchors.top: parent.top; anchors.topMargin: 2
                                    text: modelData.badge
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: Qt.rgba(1,1,1,0.7)
                                }
                            }

                            Text {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.bottomMargin: 6
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData.name
                                font.pixelSize: theme.typography.small
                                color: theme.colors.textPrimary
                                elide: Text.ElideRight
                                leftPadding: 4; rightPadding: 4
                            }

                            MouseArea { id: itemMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                        }
                    }
                }
            }

            // Not signed in: empty state
            ColumnLayout {
                anchors.centerIn: parent
                visible: !signedIn
                spacing: theme.spacing.sm

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u2606"
                    font.pixelSize: 32
                    color: theme.colors.textDim
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sign in to access your library"
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textMuted
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120; height: 28
                    color: signInMa.containsMouse ? Qt.lighter(theme.colors.accent, 1.1) : theme.colors.accent
                    radius: 2

                    Text { anchors.centerIn: parent; text: "Sign In"; font.pixelSize: theme.typography.small; font.weight: Font.Medium; color: theme.colors.textOnAccent }
                    MouseArea { id: signInMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: signedIn = true }
                }
            }
        }
    }
}
