import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Fognitix

Dialog {
    id: root
    modal: true
    title: qsTr("Export media")
    width: Math.min(640, (ApplicationWindow.window ? ApplicationWindow.window.width : 900) - 40)
    height: Math.min(520, (ApplicationWindow.window ? ApplicationWindow.window.height : 800) - 40)
    padding: 16

    standardButtons: Dialog.NoButton

    ListModel {
        id: queueModel
    }

    FileDialog {
        id: outFileDlg
        title: qsTr("Output file")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("MP4 (*.mp4)"), qsTr("MOV (*.mov)"), qsTr("All (*)")]
        defaultSuffix: "mp4"
        onAccepted: {
            if (selectedFile.isValid())
                outPathField.text = selectedFile.toLocalFile()
        }
    }

    function presetLabelForIndex(i) {
        const labels = ["H.264 1080p", "H.264 720p", "HEVC 1080p", "Apple ProRes 422 HQ (stub)"]
        return labels[Math.max(0, Math.min(i, labels.length - 1))]
    }

    footer: RowLayout {
        spacing: 10
        Button {
            text: qsTr("Close")
            onClicked: root.close()
        }
        Item {
            Layout.fillWidth: true
        }
        Button {
            text: qsTr("Add to queue")
            onClicked: {
                const p = outPathField.text.trim()
                if (!p.length)
                    return
                queueModel.append({
                    "path": p,
                    "preset": presetLabelForIndex(presetCombo.currentIndex)
                })
            }
        }
        Button {
            text: qsTr("Export now")
            highlighted: true
            onClicked: {
                if (!mainWindow)
                    return
                const p = outPathField.text.trim()
                if (!p.length)
                    return
                mainWindow.exportMedia(p, presetLabelForIndex(presetCombo.currentIndex))
                root.close()
            }
        }
    }

    ColumnLayout {
        id: exportContent
        spacing: theme.spacing.s2
        width: root.availableWidth
        implicitHeight: 400

        Theme {
            id: theme
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label {
                text: qsTr("Preset")
                color: theme.colors.textMuted
            }
            ComboBox {
                id: presetCombo
                Layout.fillWidth: true
                model: [qsTr("H.264 1080p"), qsTr("H.264 720p"), qsTr("HEVC 1080p"), qsTr("Apple ProRes 422 HQ (stub)")]
            }
        }

        Label {
            text: qsTr("Output path")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            TextField {
                id: outPathField
                Layout.fillWidth: true
                placeholderText: qsTr("C:\\Exports\\MyFilm.mp4")
                color: theme.colors.textPrimary
                background: Rectangle {
                    color: theme.colors.panelBackground
                    border.color: theme.colors.borderColor
                    radius: 4
                }
            }
            Button {
                text: qsTr("Browse…")
                onClicked: outFileDlg.open()
            }
        }

        Label {
            text: qsTr("Queue")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: theme.colors.secondaryPanel
            border.color: theme.colors.borderSubtle
            radius: 6

            ListView {
                id: queueView
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                model: queueModel
                spacing: 4

                delegate: Rectangle {
                    width: queueView.width
                    height: row.implicitHeight + 12
                    radius: 4
                    color: theme.colors.panelBackground
                    border.color: theme.colors.borderHairline

                    RowLayout {
                        id: row
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: model.preset
                                color: theme.colors.textPrimary
                                font.pixelSize: theme.typography.caption
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                text: model.path
                                color: theme.colors.textDisabled
                                font.pixelSize: theme.typography.micro
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                        ToolButton {
                            text: "×"
                            onClicked: queueModel.remove(index)
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: queueModel.count === 0
                    text: qsTr("No jobs queued — add a path, pick a preset, then “Add to queue”.")
                    color: theme.colors.textDisabled
                    wrapMode: Text.WordWrap
                    width: parent.width - 24
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
