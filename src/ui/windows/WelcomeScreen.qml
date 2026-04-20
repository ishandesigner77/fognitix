import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.primaryBackground
    Theme { id: theme }

    signal newProjectRequested()
    signal openProjectRequested()
    signal openRecent(string path)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 48

        // Left column — brand + primary actions
        ColumnLayout {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            spacing: 18

            RowLayout {
                spacing: 12
                Rectangle {
                    width: 44; height: 32; radius: 6
                    color: theme.colors.accent
                    Label {
                        anchors.centerIn: parent
                        text: "Fx"; color: "#fff"
                        font.pixelSize: 16; font.weight: Font.Bold
                    }
                }
                ColumnLayout {
                    spacing: 0
                    Label {
                        text: "Fognitix"
                        color: theme.colors.textPrimary
                        font.pixelSize: 22; font.weight: Font.Medium
                    }
                    Label {
                        text: qsTr("Professional video editor")
                        color: theme.colors.textSecondary
                        font.pixelSize: 11
                    }
                }
            }

            Item { Layout.preferredHeight: 8 }

            Button {
                Layout.fillWidth: true
                text: qsTr("New Project")
                implicitHeight: 40
                onClicked: root.newProjectRequested()
                background: Rectangle {
                    color: parent.hovered ? theme.colors.accentHover : theme.colors.accent
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 13; font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Open Project…")
                implicitHeight: 40
                onClicked: root.openProjectRequested()
                background: Rectangle {
                    color: parent.hovered ? theme.colors.elevated : theme.colors.secondaryPanel
                    border.color: theme.colors.borderColor
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: theme.colors.textPrimary
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSubtle }

            Label {
                text: qsTr("QUICK START")
                color: theme.colors.textDisabled
                font.pixelSize: 10; font.letterSpacing: 1.5
            }
            Repeater {
                model: [
                    qsTr("Drop footage into the Media Pool, then drag to the timeline."),
                    qsTr("Press Ctrl+Shift+A to open the AI agent."),
                    qsTr("Use J K L for shuttle playback. Press I and O to mark."),
                    qsTr("Everything is keyboard-driven — see Edit → Keyboard Shortcuts.")
                ]
                delegate: Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: "• " + modelData
                    color: theme.colors.textSecondary
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillHeight: true }

            Label {
                text: qsTr("v0.1 · Qt 6 · GPU accelerated")
                color: theme.colors.textDisabled
                font.pixelSize: 10
            }
        }

        // Right column — recent projects
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Label {
                text: qsTr("RECENT PROJECTS")
                color: theme.colors.textDisabled
                font.pixelSize: 10; font.letterSpacing: 1.5
            }

            ListView {
                id: recentList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: mainWindow && mainWindow.recentProjectCount > 0 ? mainWindow.recentProjectCount : 0

                delegate: Rectangle {
                    width: recentList.width
                    height: 52
                    radius: 6
                    color: rMa.containsMouse ? theme.colors.secondaryPanel : "transparent"
                    border.color: rMa.containsMouse ? theme.colors.borderColor : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12
                        Rectangle {
                            width: 32; height: 32; radius: 4
                            color: theme.colors.accentMuted
                            Label {
                                anchors.centerIn: parent
                                text: "\u25A2"
                                color: theme.colors.accent
                                font.pixelSize: 14
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: qsTr("Recent project ") + (index + 1)
                                color: theme.colors.textPrimary
                                font.pixelSize: 12
                            }
                            Label {
                                text: mainWindow ? mainWindow.lastRecentProjectPath() : ""
                                visible: index === 0
                                color: theme.colors.textDisabled
                                font.pixelSize: 10
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                    }
                    MouseArea {
                        id: rMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (mainWindow && index === 0) mainWindow.openLastRecentProject()
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: recentList.count === 0
                    text: qsTr("No recent projects yet — start a new one.")
                    color: theme.colors.textDisabled
                    font.pixelSize: 12
                }
            }
        }
    }
}
