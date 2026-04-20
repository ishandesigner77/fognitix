import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Fognitix

Dialog {
    id: root
    modal: true
    title: qsTr("New project")
    width: Math.min(560, (ApplicationWindow.window ? ApplicationWindow.window.width : 900) - 80)
    standardButtons: Dialog.NoButton
    padding: 16

    property url folderUrl

    function urlToLocalPath(u) {
        if (!u)
            return ""
        const s = (typeof u === "string") ? u : u.toString()
        if (s.indexOf("file:///") === 0)
            return decodeURIComponent(s.substring(8))
        if (s.indexOf("file://") === 0)
            return decodeURIComponent(s.substring(7))
        return s
    }

    function openWithDefaults() {
        if (typeof fognitixDefaultProjectDirUrl === "string" && fognitixDefaultProjectDirUrl.length > 0) {
            folderUrl = Qt.url(fognitixDefaultProjectDirUrl)
            folderText.text = urlToLocalPath(folderUrl)
        } else {
            folderUrl = Qt.url("file:///")
            folderText.text = ""
        }
        projectNameField.text = qsTr("Untitled_Project")
        cbDefaultTracks.checked = true
        presetCombo.currentIndex = 0
        colorSpaceCombo.currentIndex = 0
        open()
    }

    FolderDialog {
        id: pickFolder
        title: qsTr("Project folder")
        currentFolder: root.folderUrl
        onAccepted: {
            root.folderUrl = selectedFolder
            folderText.text = urlToLocalPath(selectedFolder)
        }
    }

    ColumnLayout {
        id: content
        spacing: theme.spacing.s2
        width: root.availableWidth

        Theme {
            id: theme
        }

        Label {
            text: qsTr("Project name")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        TextField {
            id: projectNameField
            Layout.fillWidth: true
            placeholderText: qsTr("MyProject")
            color: theme.colors.textPrimary
            font.pixelSize: theme.typography.body
            background: Rectangle {
                color: theme.colors.panelBackground
                border.color: theme.colors.borderColor
                radius: 4
            }
        }

        Label {
            text: qsTr("Location")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            TextField {
                id: folderText
                Layout.fillWidth: true
                readOnly: true
                placeholderText: qsTr("Choose a folder…")
                color: theme.colors.textPrimary
                background: Rectangle {
                    color: theme.colors.panelBackground
                    border.color: theme.colors.borderColor
                    radius: 4
                }
            }
            Button {
                text: qsTr("Browse…")
                onClicked: pickFolder.open()
            }
        }

        Label {
            text: qsTr("Preset")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        ComboBox {
            id: presetCombo
            Layout.fillWidth: true
            model: [qsTr("HD 1080p · 30 fps"), qsTr("HD 720p · 30 fps"), qsTr("UHD 4K · 24 fps")]
        }

        Label {
            text: qsTr("Working color space")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        ComboBox {
            id: colorSpaceCombo
            Layout.fillWidth: true
            model: [qsTr("Rec.709 Gamma 2.4"), qsTr("sRGB"), qsTr("Rec.2020 (preview)")]
        }

        Label {
            text: qsTr("Composition background")
            color: theme.colors.textMuted
            font.pixelSize: theme.typography.caption
        }
        Rectangle {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 28
            radius: 4
            color: "#0a0a0c"
            border.color: theme.colors.borderSubtle
            border.width: 1
        }

        CheckBox {
            id: cbDefaultTracks
            Layout.fillWidth: true
            text: qsTr("Create default multi-track layout (V3–V1, A1–A2, Text, Adj.)")
            checked: true
        }
    }

    footer: RowLayout {
        spacing: 10
        Item {
            Layout.fillWidth: true
        }
        Button {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        Button {
            text: qsTr("Create")
            highlighted: true
            onClicked: {
                if (!mainWindow)
                    return
                let base = projectNameField.text.trim()
                if (!base.length)
                    base = qsTr("Untitled_Project")
                base = base.replace(/[\\/:*?"<>|]+/g, "_")
                const folder = folderText.text.trim()
                if (!folder.length)
                    return
                const sep = (folder.endsWith("/") || folder.endsWith("\\")) ? "" : (Qt.platform.os === "windows" ? "\\" : "/")
                const fullPath = folder + sep + base + ".fognitix.sqlite"
                mainWindow.createNewProject(fullPath, cbDefaultTracks.checked)
                const win = ApplicationWindow.window
                if (win) {
                    win.showWelcomeHub = false
                    Qt.callLater(mainWindow.refreshPreview)
                }
                root.close()
            }
        }
    }
}
