import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Fognitix

ApplicationWindow {
    id: root
    width: 1440
    height: 900
    minimumWidth: 1024
    minimumHeight: 640
    visible: true
    title: qsTr("Fognitix — AI Motion Editor") + (mainWindow ? (" — " + mainWindow.projectName) : "")

    onVisibleChanged: {
        if (visible && mainWindow)
            Qt.callLater(mainWindow.refreshPreview)
    }
    onActiveChanged: {
        if (active && mainWindow)
            Qt.callLater(mainWindow.refreshPreview)
    }

    color: theme.colors.windowRoot
    // Full palette so Fusion menus / ComboBox popups match premium dark chrome (not flat grey)
    palette.window: theme.colors.windowRoot
    palette.windowText: theme.colors.textPrimary
    palette.base: theme.colors.chromePopup
    palette.alternateBase: theme.colors.panelAlt
    palette.text: theme.colors.textPrimary
    palette.button: theme.colors.surfaceHigh
    palette.buttonText: theme.colors.textPrimary
    palette.highlight: theme.colors.accentMuted
    palette.highlightedText: theme.colors.textPrimary
    palette.mid: theme.colors.chromePopupBorder
    palette.midlight: theme.colors.surfacePeak
    palette.dark: theme.colors.borderHard
    palette.light: theme.colors.surfaceRaised
    palette.shadow: "#80000000"
    palette.placeholderText: theme.colors.textDisabled
    palette.accent: theme.colors.accent
    palette.link: theme.colors.accentHover
    palette.linkVisited: theme.colors.accentActive

    Theme { id: theme }

    property bool showWelcomeHub: false

    function prepareAndOpenNewProject() {
        newProjectForm.openWithDefaults()
    }
    function openProjectDialog() { openProjectDlg.open() }
    function openSaveProjectAsDialog() { saveProjectDlg.open() }
    function openImportDialog() {
        if (mainWindow)
            mainWindow.openImportMediaDialog()
        else
            importDlg.open()
    }
    function openExportDialog() {
        exportForm.open()
    }
    function openCompositionSettingsDialog() {
        compositionDlg.open()
    }
    function openRenderQueuePanel() { exportForm.open() }
    function focusAiChat() { editor.focusAI() }
    function openAboutDialog() { aboutDlg.open() }
    function resetWindowLayout() { if (editor && typeof editor.resetWindowLayout === "function") editor.resetWindowLayout() }

    property alias editor: editor
    menuBar: AppMenuBar { menuHost: root }

    // ── Settings window (singleton) ──────────────────────────────────────────
    SettingsWindow { id: settingsWin }

    function openSettingsWindow() { settingsWin.show(); settingsWin.raise() }
    function openSettingsToTab(tab) { settingsWin.currentTab = tab; openSettingsWindow() }

    // ── Central shortcut manager ──────────────────────────────────────────────
    ShortcutManager {
        id: shortcuts
        onNewProjectRequested:       root.prepareAndOpenNewProject()
        onOpenProjectRequested:      openProjectDlg.open()
        onSaveProjectRequested:      if (mainWindow) mainWindow.saveProject()
        onSaveProjectAsRequested:    saveProjectDlg.open()
        onImportMediaRequested:      root.openImportDialog()
        onExportMediaRequested:      root.openExportDialog()
        onToggleFullscreenRequested: root.visibility === Window.FullScreen ? root.showNormal() : root.showFullScreen()
        onOpenPanelRequested: function(name) {
            if (name === "ai")         editor.focusAI()
            else if (name === "effects") editor.focusEffectsPanel()
        }
        onOpenSettingsRequested:      root.openSettingsWindow()
        onFocusAIRequested:           editor.focusAI()
        onFocusQuickCommandRequested: editor.focusAI()
    }

    Connections {
        target: mainWindow
        function onRequestOpenDialog(what) {
            if (what === "import")
                root.openImportDialog()
            else if (what === "export")
                root.openExportDialog()
            else if (what === "settings")
                root.openSettingsWindow()
        }
    }

    Item {
        anchors.fill: parent

        EditorWindow {
            id: editor
            anchors.fill: parent
            openImportFn: function () { importDlg.open() }
            openExportFn: function () { root.openExportDialog() }
        }

        HomeScreen {
            id: hub
            anchors.fill: parent
            visible: root.showWelcomeHub
            z: 200

            onRequestNewProject: root.prepareAndOpenNewProject()
            onRequestOpenProject: openProjectDlg.open()
            onRequestContinueLast: {
                mainWindow.openLastRecentProject()
                root.showWelcomeHub = false
                if (mainWindow)
                    Qt.callLater(mainWindow.refreshPreview)
            }
            onRequestEnterWorkspace: {
                root.showWelcomeHub = false
                if (mainWindow)
                    Qt.callLater(mainWindow.refreshPreview)
            }
            onRequestOpenRecent: function (path) {
                if (mainWindow && path.length > 0)
                    mainWindow.openProject(path)
                root.showWelcomeHub = false
                if (mainWindow)
                    Qt.callLater(mainWindow.refreshPreview)
            }
        }
    }

    footer: StatusBar {
        message: appState ? appState.statusMessage : ""
    }

    SplashScreen {
        id: splash
        onFinished: root.showWelcomeHub = true
    }

    NewProjectDialog {
        id: newProjectForm
    }

    CompositionSettingsDialog {
        id: compositionDlg
    }

    ExportDialog {
        id: exportForm
    }

    FileDialog {
        id: openProjectDlg
        title: qsTr("Open project")
        nameFilters: [qsTr("Fognitix project (*.fognitix.sqlite *.sqlite)"), qsTr("All (*)")]
        onAccepted: {
            if (openProjectDlg.selectedFile.isValid())
                mainWindow.openProject(openProjectDlg.selectedFile.toLocalFile())
            root.showWelcomeHub = false
            if (mainWindow)
                Qt.callLater(mainWindow.refreshPreview)
        }
    }

    FileDialog {
        id: saveProjectDlg
        title: qsTr("Save project as")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("Fognitix project (*.fognitix.sqlite)")]
        onAccepted: {
            if (saveProjectDlg.selectedFile.isValid())
                mainWindow.saveProjectAs(saveProjectDlg.selectedFile.toLocalFile())
        }
    }

    FileDialog {
        id: importDlg
        title: qsTr("Import media")
        nameFilters: [qsTr("All Media (*.mp4 *.mov *.mkv *.avi *.webm *.m4v *.wmv *.flv *.wav *.mp3 *.aac *.flac *.ogg *.m4a *.wma *.opus *.png *.jpg *.jpeg *.bmp *.tiff *.tif *.gif *.webp *.tga *.exr *.dpx *.hdr)"),
                      qsTr("Video (*.mp4 *.mov *.mkv *.avi *.webm *.m4v *.wmv *.flv)"),
                      qsTr("Audio (*.wav *.mp3 *.aac *.flac *.ogg *.m4a *.wma *.opus)"),
                      qsTr("Image (*.png *.jpg *.jpeg *.bmp *.tiff *.tif *.gif *.webp *.tga *.exr *.dpx *.hdr)"),
                      qsTr("All (*)")]
        onAccepted: {
            if (importDlg.selectedFile.isValid())
                mainWindow.importMedia(importDlg.selectedFile.toLocalFile())
        }
    }

    Dialog {
        id: aboutDlg
        title: qsTr("About Fognitix")
        modal: true
        standardButtons: Dialog.Close
        anchors.centerIn: parent
        width: 420
        Column {
            spacing: 10
            width: parent.width
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Fognitix — AI Motion Editor\n\nA pro-grade video editor with AI copilot.\nDaVinci × Premiere × After Effects × Groq AI.")
                color: theme.colors.textPrimary
            }
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: fxAssets ? (qsTr("Indexed PNG assets: ") + fxAssets.assetManifestCount) : ""
                color: theme.colors.textSecondary
                font.pixelSize: 11
            }
        }
    }
}
