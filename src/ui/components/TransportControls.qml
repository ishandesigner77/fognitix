import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

RowLayout {
    id: root
    spacing: 2

    Theme { id: theme }

    // Jump to start
    ToolButton {
        id: btnStart
        text: theme.icons.stepBack
        font.pixelSize: 14
        implicitWidth: 32
        implicitHeight: 32
        ToolTip.text: qsTr("Jump to start  (Home)")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        onClicked: if (appState) appState.playheadSeconds = 0
        background: Rectangle {
            color: btnStart.hovered ? theme.colors.elevated : "transparent"
            radius: 3
        }
        contentItem: Text {
            text: btnStart.text
            font: btnStart.font
            color: theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Step back one frame
    ToolButton {
        id: btnFrameBack
        text: "\u25C4\u25C4"
        font.pixelSize: 10
        implicitWidth: 28
        implicitHeight: 32
        ToolTip.text: qsTr("Step back  (\u2190)")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        onClicked: if (appState) appState.playheadSeconds = Math.max(0, appState.playheadSeconds - (1/30))
        background: Rectangle {
            color: btnFrameBack.hovered ? theme.colors.elevated : "transparent"
            radius: 3
        }
        contentItem: Text {
            text: btnFrameBack.text
            font: btnFrameBack.font
            color: theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Play / Pause — primary button
    ToolButton {
        id: btnPlay
        implicitWidth: 38
        implicitHeight: 38
        ToolTip.text: appState && appState.isPlaying ? qsTr("Pause  (Space)") : qsTr("Play  (Space)")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        onClicked: if (appState) appState.isPlaying = !appState.isPlaying
        background: Rectangle {
            color: btnPlay.hovered ? theme.colors.accentHover : theme.colors.accent
            radius: 4
        }
        contentItem: Text {
            text: (appState && appState.isPlaying) ? theme.icons.pause : theme.icons.play
            font.pixelSize: 15
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Step forward one frame
    ToolButton {
        id: btnFrameFwd
        text: "\u25BA\u25BA"
        font.pixelSize: 10
        implicitWidth: 28
        implicitHeight: 32
        ToolTip.text: qsTr("Step forward  (\u2192)")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        onClicked: {
            if (appState)
                appState.playheadSeconds = appState.playheadSeconds + (1 / 30)
        }
        background: Rectangle {
            color: btnFrameFwd.hovered ? theme.colors.elevated : "transparent"
            radius: 3
        }
        contentItem: Text {
            text: btnFrameFwd.text
            font: btnFrameFwd.font
            color: theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Stop
    ToolButton {
        id: btnStop
        text: theme.icons.stop
        font.pixelSize: 12
        implicitWidth: 32
        implicitHeight: 32
        ToolTip.text: qsTr("Stop")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        onClicked: { if (appState) { appState.isPlaying = false; appState.playheadSeconds = 0 } }
        background: Rectangle {
            color: btnStop.hovered ? theme.colors.elevated : "transparent"
            radius: 3
        }
        contentItem: Text {
            text: btnStop.text
            font: btnStop.font
            color: theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item { width: 8 }

    // Loop toggle
    ToolButton {
        id: btnLoop
        checkable: true
        text: theme.icons.loop
        font.pixelSize: 14
        implicitWidth: 32
        implicitHeight: 32
        ToolTip.text: qsTr("Loop playback")
        ToolTip.visible: hovered
        ToolTip.delay: 500
        background: Rectangle {
            color: btnLoop.checked ? theme.colors.accentMuted
                 : btnLoop.hovered ? theme.colors.elevated : "transparent"
            border.color: btnLoop.checked ? theme.colors.accent : "transparent"
            radius: 3
        }
        contentItem: Text {
            text: btnLoop.text
            font: btnLoop.font
            color: btnLoop.checked ? theme.colors.accent : theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item { width: 12 }

    // Timecode display — prominent, primary numeric readout
    Rectangle {
        width: 164
        height: 34
        color: "#0c0c0c"
        border.color: theme.colors.borderSoft
        border.width: 1
        radius: 4

        Label {
            id: timecodeLabel
            anchors.fill: parent
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter
            font.family: "Consolas, monospace"
            font.pixelSize: 19
            font.weight: Font.Medium
            font.letterSpacing: 0.5
            color: theme.colors.textPrimary
            text: {
                if (!appState)
                    return "00:00:00:00"
                const s = appState.playheadSeconds
                const fps = 30
                const h = Math.floor(s / 3600)
                const m = Math.floor((s % 3600) / 60)
                const ss = Math.floor(s % 60)
                const fr = Math.floor((s % 1) * fps)
                return String(h).padStart(2, "0") + ":" +
                       String(m).padStart(2, "0") + ":" +
                       String(ss).padStart(2, "0") + ":" +
                       String(fr).padStart(2, "0")
            }
        }
    }

    Item { width: 4 }

    // FPS label
    Label {
        text: "30 fps"
        color: theme.colors.textDisabled
        font.pixelSize: theme.typography.caption
        font.family: theme.typography.fontFamily
    }
}
