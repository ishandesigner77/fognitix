import QtQuick.Controls
import Fognitix

Menu {
    id: root
    property var menuHost: null

    title: qsTr("&Edit")

    Action {
        text: qsTr("Undo")
        shortcut: "Ctrl+Z"
        enabled: mainWindow && mainWindow.canUndo
        onTriggered: if (mainWindow) mainWindow.undo()
    }
    Action {
        text: qsTr("Redo")
        shortcut: "Ctrl+Shift+Z"
        enabled: mainWindow && mainWindow.canRedo
        onTriggered: if (mainWindow) mainWindow.redo()
    }
    MenuSeparator {}
    Action {
        text: qsTr("Cut")
        shortcut: "Ctrl+X"
        onTriggered: if (mainWindow) mainWindow.cutSelection()
    }
    Action {
        text: qsTr("Copy")
        shortcut: "Ctrl+C"
        onTriggered: if (mainWindow) mainWindow.copySelection()
    }
    Action {
        text: qsTr("Paste")
        shortcut: "Ctrl+V"
        onTriggered: if (mainWindow) mainWindow.paste()
    }
    Action {
        text: qsTr("Duplicate")
        shortcut: "Ctrl+D"
        enabled: false
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Not in this build")
    }
    Action {
        text: qsTr("Delete")
        shortcut: "Del"
        onTriggered: if (mainWindow) mainWindow.deleteSelection()
    }
    MenuSeparator {}
    Action {
        text: qsTr("Split at Playhead")
        shortcut: "Ctrl+K"
        onTriggered: if (mainWindow) mainWindow.splitAtPlayhead()
    }
    Action {
        text: qsTr("Ripple delete")
        enabled: false
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Not in this build")
    }
    MenuSeparator {}
    Menu {
        title: qsTr("Purge")
        Action {
            text: qsTr("All Memory & Disk Cache…")
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Not in this build")
        }
        Action {
            text: qsTr("Undo History")
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Not in this build")
        }
    }
    MenuSeparator {}
    Action {
        text: qsTr("Preferences…")
        enabled: false
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Not in this build")
    }
}
