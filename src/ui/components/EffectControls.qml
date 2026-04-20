import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    /** When true, hide the title row (parent panel supplies the chrome). */
    property bool compact: false
    implicitHeight: contentCol.implicitHeight + (compact ? 12 : 20)
    color: theme.colors.panelBackground
    border.color: theme.colors.borderColor
    border.width: 1
    clip: true

    Theme { id: theme }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: compact ? 8 : 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: !root.compact
            Label {
                text: qsTr("EFFECT CONTROLS")
                color: theme.colors.textDisabled
                font.pixelSize: theme.typography.micro
                font.letterSpacing: theme.typography.letterSpacingCaps
                font.weight: Font.Bold
            }
            Item { Layout.fillWidth: true }
            Label {
                text: mainWindow && mainWindow.selectedClipId.length > 0
                      ? mainWindow.selectedClipId : qsTr("No clip selected")
                color: theme.colors.textSecondary
                font.pixelSize: theme.typography.caption
                elide: Text.ElideRight
                Layout.maximumWidth: 180
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            visible: !root.compact
            color: theme.colors.borderSubtle
        }

        RowLayout {
            Layout.fillWidth: true
            visible: root.compact
            Label {
                text: mainWindow && mainWindow.selectedClipId.length > 0
                      ? mainWindow.selectedClipId : qsTr("No clip selected")
                color: theme.colors.textSecondary
                font.pixelSize: theme.typography.caption
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                text: qsTr("Opacity")
                color: theme.colors.textMuted
                font.pixelSize: theme.typography.caption
                Layout.preferredWidth: 72
            }
            Slider {
                id: opSl
                Layout.fillWidth: true
                from: 0
                to: 100
                value: 100
            }
            Label {
                text: Math.round(opSl.value) + "%"
                color: theme.colors.timecodeBright
                font.pixelSize: theme.typography.caption
                font.family: "Consolas"
                Layout.preferredWidth: 40
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                text: qsTr("Scale")
                color: theme.colors.textMuted
                font.pixelSize: theme.typography.caption
                Layout.preferredWidth: 72
            }
            Slider {
                id: scSl
                Layout.fillWidth: true
                from: 10
                to: 200
                value: 100
            }
            Label {
                text: Math.round(scSl.value) + "%"
                color: theme.colors.timecodeBright
                font.pixelSize: theme.typography.caption
                font.family: "Consolas"
                Layout.preferredWidth: 40
            }
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Full effect stack and keyframes follow the selected timeline clip.")
            wrapMode: Text.WordWrap
            color: theme.colors.textDisabled
            font.pixelSize: theme.typography.micro
        }
    }
}
