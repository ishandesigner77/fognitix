import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground
    Theme { id: theme }

    // History populated as mainWindow emits changes
    property int currentStateIndex: historyModel.count - 1

    ListModel {
        id: historyModel
        ListElement { action: "Project created";     icon: "\u25A2"; timestamp: "00:00" }
    }

    function pushHistory(action, icon) {
        const now = new Date()
        const ts = String(now.getHours()).padStart(2,"0") + ":" + String(now.getMinutes()).padStart(2,"0") + ":" + String(now.getSeconds()).padStart(2,"0")
        if (historyModel.count >= 200) historyModel.remove(0)
        historyModel.append({ action: action, icon: icon || "\u25AA", timestamp: ts })
        root.currentStateIndex = historyModel.count - 1
        Qt.callLater(() => historyList.positionViewAtEnd())
    }

    Connections {
        target: mainWindow
        function onTimelineChanged() { root.pushHistory("Timeline changed", "\u25C6") }
        function onProjectNameChanged() { root.pushHistory("Project: " + (mainWindow ? mainWindow.projectName : ""), "\u25A2") }
        function onAiLogAppended(line) { root.pushHistory("AI: " + line.substring(0,40), "\u2217") }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 6

                Label {
                    text: qsTr("HISTORY")
                    color: theme.colors.textDisabled
                    font.pixelSize: 10; font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }

                Label {
                    text: historyModel.count + qsTr(" steps")
                    color: theme.colors.textDisabled
                    font.pixelSize: 10
                }

                ToolButton {
                    implicitWidth: 24; implicitHeight: 24
                    text: "\u21BA"
                    font.pixelSize: 12
                    ToolTip.text: qsTr("Clear history")
                    ToolTip.visible: hovered; ToolTip.delay: 600
                    background: Rectangle { color: parent.hovered ? theme.colors.elevated : "transparent"; radius: 4 }
                    contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        historyModel.clear()
                        root.pushHistory("History cleared", "\u21BA")
                        root.currentStateIndex = 0
                    }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
        }

        // History list
        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0
            model: historyModel

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { color: theme.colors.scrollbar; radius: 3; implicitWidth: 6 }
                background: Rectangle { color: "transparent" }
            }

            delegate: Rectangle {
                id: hRow
                width: historyList.width
                height: 32
                color: {
                    if (index > root.currentStateIndex) return "transparent"
                    if (hMA.containsMouse) return theme.colors.secondaryPanel
                    if (index === root.currentStateIndex) return theme.colors.accentMuted
                    return "transparent"
                }
                opacity: index > root.currentStateIndex ? 0.35 : 1.0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 8

                    // Step number
                    Label {
                        text: String(index + 1).padStart(3, "\u2007")
                        color: theme.colors.textDisabled
                        font.pixelSize: 10; font.family: "Consolas"
                        Layout.preferredWidth: 26
                    }

                    // Icon
                    Label {
                        text: model.icon || "\u25AA"
                        color: index === root.currentStateIndex ? theme.colors.accent : theme.colors.textSecondary
                        font.pixelSize: 11
                    }

                    // Action name
                    Label {
                        text: model.action
                        color: index === root.currentStateIndex ? theme.colors.textPrimary : theme.colors.textSecondary
                        font.pixelSize: 11
                        font.weight: index === root.currentStateIndex ? Font.Medium : Font.Normal
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Timestamp
                    Label {
                        text: model.timestamp
                        color: theme.colors.textDisabled
                        font.pixelSize: 10; font.family: "Consolas"
                    }
                }

                // Current state indicator
                Rectangle {
                    visible: index === root.currentStateIndex
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2; height: 16
                    color: theme.colors.accent
                    radius: 1
                }

                MouseArea {
                    id: hMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentStateIndex = index
                        // Undo/redo to the target state
                        if (mainWindow) {
                            const diff = root.currentStateIndex - (historyModel.count - 1)
                            if (diff < 0) for (var i = 0; i > diff; i--) mainWindow.undo()
                            else for (var j = 0; j < diff; j++) mainWindow.redo()
                        }
                    }
                }

                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle; opacity: 0.3 }
            }
        }

        // Snapshots strip
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Label {
                    text: qsTr("Save snapshot:")
                    color: theme.colors.textDisabled
                    font.pixelSize: 10
                }

                TextField {
                    id: snapName
                    Layout.fillWidth: true
                    height: 22
                    placeholderText: qsTr("Name…")
                    font.pixelSize: 11
                    color: theme.colors.textPrimary
                    leftPadding: 6
                    background: Rectangle { color: theme.colors.elevated; border.color: theme.colors.borderColor; radius: 3 }
                    onAccepted: saveSnap.clicked()
                }

                Button {
                    id: saveSnap
                    text: qsTr("Save")
                    implicitHeight: 22; font.pixelSize: 10
                    background: Rectangle { color: parent.hovered ? theme.colors.accentHover : theme.colors.accent; radius: 3 }
                    contentItem: Text { text: parent.text; color: "#fff"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (snapName.text.trim()) {
                            root.pushHistory("[Snapshot] " + snapName.text, "\u2605")
                            snapName.text = ""
                        }
                    }
                }
            }
        }
    }
}
