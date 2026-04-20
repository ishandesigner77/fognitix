import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.windowRoot

    signal requestNewProject()
    signal requestOpenProject()
    signal requestContinueLast()
    signal requestEnterWorkspace()
    signal requestOpenRecent(string path)

    Theme { id: theme }

    readonly property bool hasFxPack: fxAssets && fxAssets.exists("UIShell_Folder.png")

    readonly property var hubRows: [
        {
            icon: "UIShell_Desktop.png",
            title: qsTr("New project"),
            subtitle: qsTr("Choose file name and folder — SQLite project database"),
            strong: true,
            action: "new"
        },
        {
            icon: "UIShell_Folder.png",
            title: qsTr("Open project…"),
            subtitle: qsTr("Continue work on an existing .fognitix.sqlite project"),
            strong: false,
            action: "open"
        },
        {
            icon: "UIShell_MyDocuments.png",
            title: qsTr("Continue last project"),
            subtitle: qsTr("Jump back to your most recently opened timeline"),
            strong: false,
            action: "last"
        }
    ]

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.colors.windowRoot }
            GradientStop { position: 1.0; color: "#060608" }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.35
        height: width
        radius: width / 2
        opacity: 0.1
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.colors.accent }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 18
        width: Math.min(640, parent.width - 80)

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "FOGNITIX"
            color: theme.colors.textPrimary
            font.pixelSize: 28
            font.weight: Font.Black
            font.letterSpacing: 6
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Professional motion workspace · Timeline · AI copilot")
            color: theme.colors.textSecondary
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            visible: root.hasFxPack
            text: qsTr("High-density icon pack detected — shown with Fognitix accent treatment.")
            color: theme.colors.textDisabled
            font.pixelSize: 10
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.maximumWidth: 480
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: hubLayout.implicitHeight + 40
            radius: 16
            color: theme.colors.panelBackground
            border.color: theme.colors.edgeHighlight
            border.width: 1

            ColumnLayout {
                id: hubLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Repeater {
                    id: hubRepeater
                    model: root.hubRows.length

                    delegate: Rectangle {
                        id: rowRoot
                        required property int index
                        readonly property var row: root.hubRows[index]
                        readonly property bool dimmed: row.action === "last" && (!mainWindow || mainWindow.recentProjectCount <= 0)

                        Layout.fillWidth: true
                        implicitHeight: inner.implicitHeight + 18
                        radius: 12
                        color: rowMA.containsMouse && !dimmed ? theme.colors.tertiaryPanel : theme.colors.secondaryPanel
                        border.color: row.strong ? Qt.darker(theme.colors.accent, 1.2) : theme.colors.borderSubtle
                        border.width: 1
                        opacity: dimmed ? 0.45 : 1

                        RowLayout {
                            id: inner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 56
                                Layout.preferredHeight: 56
                                radius: 10
                                color: theme.colors.previewSurround
                                border.color: theme.colors.accent
                                border.width: 1

                                Image {
                                    id: rowIcon
                                    anchors.fill: parent
                                    anchors.margins: 7
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    smooth: true
                                    readonly property string ifile: row.icon || ""
                                    source: (fxAssets && ifile.length > 0 && fxAssets.exists(ifile)) ? fxAssets.urlFor(ifile) : ""
                                    visible: source.length > 0
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: !rowIcon.visible
                                    text: row.strong ? "\u2295" : "\u25A2"
                                    font.pixelSize: 26
                                    color: theme.colors.textDisabled
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: Qt.rgba(0.83, 0.79, 0.69, 0.10)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Label {
                                    text: row.title
                                    color: theme.colors.textPrimary
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: row.subtitle
                                    color: theme.colors.textDisabled
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            Label {
                                text: "\u203A"
                                color: theme.colors.textDisabled
                                font.pixelSize: 18
                            }
                        }

                        MouseArea {
                            id: rowMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: dimmed ? Qt.ArrowCursor : Qt.PointingHandCursor
                            enabled: !dimmed
                            onClicked: {
                                if (row.action === "new")
                                    root.requestNewProject()
                                else if (row.action === "open")
                                    root.requestOpenProject()
                                else if (row.action === "last")
                                    root.requestContinueLast()
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    visible: mainWindow && mainWindow.recentProjectCount > 0
                    text: qsTr("RECENT PROJECTS")
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: theme.typography.letterSpacingCaps
                    font.weight: Font.Bold
                }

                Repeater {
                    model: mainWindow ? Math.min(5, mainWindow.recentProjectCount) : 0
                    delegate: Rectangle {
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: recentInner.implicitHeight + 14
                        radius: 10
                        color: recentMA.containsMouse ? theme.colors.tertiaryPanel : theme.colors.secondaryPanel
                        border.color: theme.colors.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: recentInner
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 52
                                radius: 8
                                color: theme.colors.previewSurround
                                border.color: theme.colors.borderHairline
                                border.width: 1

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    source: (fxAssets && fxAssets.exists("UIShell_Folder.png")) ? fxAssets.urlFor("UIShell_Folder.png") : ""
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: !fxAssets || !fxAssets.exists("UIShell_Folder.png")
                                    text: "\u25A2"
                                    font.pixelSize: 22
                                    color: theme.colors.textDisabled
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    text: {
                                        var p = mainWindow.recentProjectPathAt(index)
                                        if (!p.length)
                                            return ""
                                        var parts = p.replace(/\\/g, "/").split("/")
                                        return parts.length ? parts[parts.length - 1] : p
                                    }
                                    color: theme.colors.textPrimary
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: mainWindow.recentProjectPathAt(index)
                                    color: theme.colors.textDisabled
                                    font.pixelSize: 10
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }

                            Label {
                                text: "\u203A"
                                color: theme.colors.textDisabled
                                font.pixelSize: 16
                            }
                        }

                        MouseArea {
                            id: recentMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.requestOpenRecent(mainWindow.recentProjectPathAt(index))
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: theme.colors.borderSubtle
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 30
                    text: qsTr("Enter workspace (keep current session)")
                    flat: true
                    font.pixelSize: 11
                    onClicked: root.requestEnterWorkspace()
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: theme.colors.textAccent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
