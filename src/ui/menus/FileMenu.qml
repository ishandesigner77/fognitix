import QtQuick.Controls
import Fognitix

Menu {
    id: root
    required property var menuHost

    title: qsTr("&File")

    Action {
        text: qsTr("New Project…")
        shortcut: "Ctrl+N"
        onTriggered: menuHost.prepareAndOpenNewProject()
    }
    Action {
        text: qsTr("Open Project…")
        shortcut: "Ctrl+O"
        onTriggered: menuHost.openProjectDialog()
    }
    Menu {
        title: qsTr("Open Recent")
        Action {
            text: qsTr("Continue last…")
            enabled: mainWindow && mainWindow.recentProjectCount > 0
            onTriggered: {
                if (mainWindow)
                    mainWindow.openLastRecentProject()
            }
        }
        Action {
            text: qsTr("Clear recent (N/A)")
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Not in this build")
        }
    }
    MenuSeparator {}
    Action {
        text: qsTr("Close Project")
        enabled: false
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Not in this build")
    }
    Action {
        text: qsTr("Save")
        shortcut: "Ctrl+S"
        onTriggered: if (mainWindow) mainWindow.saveProject()
    }
    Action {
        text: qsTr("Save As…")
        shortcut: "Ctrl+Shift+S"
        onTriggered: menuHost.openSaveProjectAsDialog()
    }
    MenuSeparator {}
    Menu {
        title: qsTr("Import")
        Action {
            text: qsTr("Media…")
            shortcut: "Ctrl+I"
            onTriggered: menuHost.openImportDialog()
        }
        Action {
            text: qsTr("Multiple…")
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Not in this build")
        }
    }
    Menu {
        title: qsTr("Export")
        Action {
            text: qsTr("Movie…")
            shortcut: "Ctrl+M"
            onTriggered: menuHost.openExportDialog()
        }
        Action {
            text: qsTr("Frame…")
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Not in this build")
        }
    }
    MenuSeparator {}
    Action {
        text: qsTr("Project Settings…")
        enabled: false
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Not in this build")
    }
    MenuSeparator {}
    Action {
        text: qsTr("Exit")
        shortcut: "Ctrl+Q"
        onTriggered: Qt.quit()
    }
}
