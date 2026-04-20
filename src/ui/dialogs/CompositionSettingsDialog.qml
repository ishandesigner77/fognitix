import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Dialog {
    id: root
    modal: true
    title: qsTr("Composition settings")
    width: Math.min(440, (ApplicationWindow.window ? ApplicationWindow.window.width : 900) - 80)
    standardButtons: Dialog.Ok | Dialog.Cancel
    padding: 16

    readonly property var fpsChoices: [23.976, 24, 25, 29.97, 30, 50, 60]

    function formatDuration(sec) {
        if (!isFinite(sec) || sec < 0)
            return "—"
        const m = Math.floor(sec / 60)
        const s = Math.floor(sec % 60)
        const cs = Math.floor((sec - Math.floor(sec)) * 100)
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s + ":" + (cs < 10 ? "0" : "") + cs
    }

    function syncFpsIndex() {
        if (!mainWindow)
            return
        var v = mainWindow.compositionFps
        var best = 4
        var bestDiff = 1e9
        for (var i = 0; i < fpsChoices.length; i++) {
            var d = Math.abs(fpsChoices[i] - v)
            if (d < bestDiff) {
                bestDiff = d
                best = i
            }
        }
        fpsCombo.currentIndex = best
    }

    onOpened: syncFpsIndex()

    ColumnLayout {
        spacing: theme.spacing.s2
        width: root.availableWidth

        Theme {
            id: theme
        }

        Label {
            text: mainWindow ? mainWindow.projectName : qsTr("—")
            color: theme.colors.textPrimary
            font.pixelSize: theme.typography.body
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        GridLayout {
            columns: 2
            columnSpacing: 12
            rowSpacing: 8
            Layout.fillWidth: true

            Label {
                text: qsTr("Composition duration")
                color: theme.colors.textMuted
            }
            Label {
                text: mainWindow ? formatDuration(mainWindow.compositionDuration) : "—"
                color: theme.colors.textPrimary
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Frame rate (display / export hint)")
                color: theme.colors.textMuted
            }
            ComboBox {
                id: fpsCombo
                Layout.fillWidth: true
                model: ["23.976", "24", "25", "29.97", "30", "50", "60"]
            }

            Label {
                text: qsTr("Resolution")
                color: theme.colors.textMuted
            }
            Label {
                text: qsTr("From preview / project (wired later)")
                color: theme.colors.textSecondary
                font.pixelSize: theme.typography.caption
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Duration follows the extent of clips on the timeline. Frame rate is stored for new exports and UI timecode.")
            color: theme.colors.textDisabled
            font.pixelSize: theme.typography.micro
        }
    }

    onAccepted: {
        if (!mainWindow)
            return
        var idx = Math.max(0, Math.min(fpsCombo.currentIndex, fpsChoices.length - 1))
        mainWindow.setCompositionFps(fpsChoices[idx])
    }
}
