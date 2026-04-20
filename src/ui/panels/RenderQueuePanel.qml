import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground
    Theme { id: theme }

    property var queueItems: []
    property bool rendering: false
    property int renderingIndex: -1

    function addCurrentProject() {
        queueItems.push({
            name: mainWindow ? mainWindow.projectName : "Untitled",
            format: "H.264 1080p",
            path: "",
            status: "queued",
            progress: 0.0,
            enabled: true
        })
        queueModel.clear()
        for (var i = 0; i < queueItems.length; i++) queueModel.append(queueItems[i])
    }

    ListModel { id: queueModel }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Rectangle {
            Layout.fillWidth: true
            height: 42
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Label {
                    text: qsTr("RENDER QUEUE")
                    color: theme.colors.textDisabled
                    font.pixelSize: 10; font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("+ Add Current")
                    implicitHeight: 28; font.pixelSize: 11
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.elevated : theme.colors.secondaryPanel
                        border.color: theme.colors.borderColor; radius: 5
                    }
                    contentItem: Text {
                        text: parent.text; color: theme.colors.textSecondary; font: parent.font
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.addCurrentProject()
                }

                Button {
                    id: renderBtn
                    text: root.rendering ? qsTr("Stop") : qsTr("\u25B6  Render All")
                    implicitHeight: 28; font.pixelSize: 11
                    background: Rectangle {
                        color: root.rendering
                               ? (parent.hovered ? "#9a1c1c" : "#7f1d1d")
                               : (parent.hovered ? "#dc2626" : "#b91c1c")
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text; color: "#fff"; font: parent.font
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (root.rendering) {
                            root.rendering = false
                        } else if (queueModel.count > 0) {
                            root.rendering = true
                            root.renderingIndex = 0
                            renderTimer.start()
                        }
                    }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
        }

        // Queue list
        ListView {
            id: queueView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 1
            model: queueModel

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { color: theme.colors.scrollbar; radius: 3; implicitWidth: 6 }
                background: Rectangle { color: "transparent" }
            }

            delegate: Rectangle {
                id: qItem
                width: queueView.width
                height: 72
                color: index % 2 === 0 ? theme.colors.panelBackground : theme.colors.secondaryPanel
                opacity: model.enabled ? 1.0 : 0.5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Enable toggle
                        CheckBox {
                            checked: model.enabled
                            onCheckedChanged: queueModel.setProperty(index, "enabled", checked)
                            indicator: Rectangle {
                                width: 14; height: 14; radius: 3
                                color: parent.checked ? theme.colors.accent : theme.colors.elevated
                                border.color: parent.checked ? theme.colors.accent : theme.colors.borderColor
                                Label {
                                    anchors.centerIn: parent
                                    visible: parent.parent.checked
                                    text: "\u2713"; color: "#fff"; font.pixelSize: 9; font.weight: Font.Bold
                                }
                            }
                            background: Item {}
                        }

                        Label {
                            text: model.name || "Untitled"
                            color: theme.colors.textPrimary
                            font.pixelSize: 12; font.weight: Font.Medium
                            Layout.fillWidth: true
                        }

                        // Status badge
                        Rectangle {
                            width: statusLbl.implicitWidth + 12; height: 18; radius: 9
                            color: {
                                switch(model.status) {
                                    case "done":     return "#14532d"
                                    case "error":    return "#4a1212"
                                    case "rendering":return theme.colors.accentMuted
                                    default:         return theme.colors.tertiaryPanel
                                }
                            }
                            Label {
                                id: statusLbl
                                anchors.centerIn: parent
                                text: model.status || "queued"
                                color: {
                                    switch(model.status) {
                                        case "done":     return "#7a8470"
                                        case "error":    return theme.colors.danger
                                        case "rendering":return theme.colors.accent
                                        default:         return theme.colors.textSecondary
                                    }
                                }
                                font.pixelSize: 10; font.letterSpacing: 0.5
                            }
                        }

                        // Remove
                        ToolButton {
                            implicitWidth: 20; implicitHeight: 20
                            text: "\u2715"; font.pixelSize: 10
                            background: Rectangle { color: parent.hovered ? "#3a1a1a" : "transparent"; radius: 3 }
                            contentItem: Text { text: parent.text; color: theme.colors.danger; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: queueModel.remove(index)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: model.format || "H.264 1080p"
                            color: theme.colors.textSecondary; font.pixelSize: 11
                        }

                        Label {
                            text: "|"; color: theme.colors.borderSubtle; font.pixelSize: 11
                        }

                        Label {
                            text: model.path || qsTr("Output path not set")
                            color: model.path ? theme.colors.textSecondary : theme.colors.danger
                            font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideMiddle
                        }

                        ToolButton {
                            implicitWidth: 22; implicitHeight: 22
                            text: "\u2026"; font.pixelSize: 12
                            ToolTip.text: qsTr("Choose output path"); ToolTip.visible: hovered
                            background: Rectangle { color: parent.hovered ? theme.colors.elevated : "transparent"; radius: 3 }
                            contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }

                    ProgressBar {
                        Layout.fillWidth: true
                        visible: model.status === "rendering"
                        implicitHeight: 3
                        from: 0; to: 1
                        value: model.progress || 0
                        background: Rectangle { color: theme.colors.elevated; radius: 2 }
                        contentItem: Rectangle {
                            width: parent.visualPosition * parent.width
                            height: parent.height
                            color: theme.colors.accent
                            radius: 2
                        }
                    }
                }

                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle; opacity: 0.3 }
            }

            Label {
                anchors.centerIn: parent
                visible: queueModel.count === 0
                text: qsTr("Queue is empty\nUse Ctrl+Shift+M or click '+ Add Current'")
                color: theme.colors.textDisabled; font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Label {
                    text: queueModel.count + qsTr(" items in queue")
                    color: theme.colors.textDisabled; font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: mainWindow ? qsTr("Render progress: ") + Math.round(mainWindow.renderProgress * 100) + "%" : ""
                    color: theme.colors.textSecondary; font.pixelSize: 11
                    visible: root.rendering
                }
            }
        }
    }

    // Simulate rendering progress
    Timer {
        id: renderTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            if (!root.rendering || root.renderingIndex < 0 || root.renderingIndex >= queueModel.count) {
                root.rendering = false; stop(); return
            }
            var item = queueModel.get(root.renderingIndex)
            if (!item.enabled) { root.renderingIndex++; return }
            queueModel.setProperty(root.renderingIndex, "status", "rendering")
            var p = (item.progress || 0) + 0.01
            if (p >= 1.0) {
                queueModel.setProperty(root.renderingIndex, "progress", 1.0)
                queueModel.setProperty(root.renderingIndex, "status", "done")
                root.renderingIndex++
                if (root.renderingIndex >= queueModel.count) { root.rendering = false; stop() }
            } else {
                queueModel.setProperty(root.renderingIndex, "progress", p)
            }
        }
    }
}
