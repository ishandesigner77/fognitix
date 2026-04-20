import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    implicitHeight: 36
    height: implicitHeight
    color: theme.colors.statusBarBackground

    property string message: ""

    Theme { id: theme }

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: theme.colors.borderSubtle
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Status text — capped width so metrics / timecode never get squeezed off-screen
        Label {
            text: root.message.length > 0 ? root.message : qsTr("Ready")
            color: root.message.length > 0 ? theme.colors.textSecondary : theme.colors.textDisabled
            font.pixelSize: theme.typography.caption
            font.family: theme.typography.fontFamily
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.maximumWidth: 420
            Layout.minimumWidth: 48
        }

        Rectangle {
            width: 1
            height: 18
            color: theme.colors.borderSubtle
        }

        Label {
            text: qsTr("TC")
            color: theme.colors.textDisabled
            font.pixelSize: 9
            font.weight: Font.Bold
        }
        Label {
            id: tcPlayhead
            text: {
                if (!appState)
                    return "00:00:00:00"
                const s = appState.playheadSeconds
                const h = Math.floor(s / 3600)
                const m = Math.floor((s % 3600) / 60)
                const ss = Math.floor(s % 60)
                const fr = Math.floor((s % 1) * 30)
                return String(h).padStart(2, "0") + ":" + String(m).padStart(2, "0") + ":" + String(ss).padStart(2, "0") + ":" + String(fr).padStart(2, "0")
            }
            color: theme.colors.timecodeBright
            font.pixelSize: 12
            font.weight: Font.Medium
            font.family: "Consolas, monospace"
            Layout.minimumWidth: 118
            Layout.fillWidth: false
        }

        Label {
            text: "/"
            color: theme.colors.textDisabled
            font.pixelSize: 10
        }

        Label {
            text: {
                if (!mainWindow)
                    return "00:00:00:00"
                const s = mainWindow.compositionDuration
                const h = Math.floor(s / 3600)
                const m = Math.floor((s % 3600) / 60)
                const ss = Math.floor(s % 60)
                const fr = Math.floor((s % 1) * 30)
                return String(h).padStart(2, "0") + ":" + String(m).padStart(2, "0") + ":" + String(ss).padStart(2, "0") + ":" + String(fr).padStart(2, "0")
            }
            color: theme.colors.textSecondary
            font.pixelSize: 11
            font.family: "Consolas, monospace"
            Layout.minimumWidth: 118
            Layout.fillWidth: false
        }

        Rectangle {
            width: 1
            height: 16
            color: theme.colors.borderSubtle
        }

        Label {
            text: qsTr("1920×1080 · 30fps")
            color: theme.colors.textDisabled
            font.pixelSize: theme.typography.micro
        }

        Rectangle {
            width: 1
            height: 16
            color: theme.colors.borderSubtle
        }

        Label {
            text: mainWindow ? (qsTr("Tracks ") + mainWindow.trackCount + " · " + qsTr("Clips ") + mainWindow.clipCount) : ""
            color: theme.colors.textDisabled
            font.pixelSize: theme.typography.micro
        }

        Rectangle {
            width: 1
            height: 16
            color: theme.colors.borderSubtle
        }

        Label {
            text: mainWindow ? (qsTr("Tool: ") + mainWindow.uiToolName) : ""
            color: theme.colors.textSecondary
            font.pixelSize: theme.typography.micro
            elide: Text.ElideRight
            Layout.maximumWidth: 140
        }

        Rectangle {
            width: 1
            height: 16
            color: theme.colors.borderSubtle
        }

        Label {
            text: mainWindow && mainWindow.aiBusy ? qsTr("AI…") : qsTr("AI")
            color: mainWindow && mainWindow.aiBusy ? theme.colors.warning : theme.colors.success
            font.pixelSize: theme.typography.micro
            font.weight: Font.Medium
        }
    }
}
