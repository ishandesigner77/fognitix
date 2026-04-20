import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.spacing.panelPad
        spacing: theme.spacing.s2

        Label {
            text: qsTr("Transitions")
            font.pixelSize: theme.typography.section
            font.weight: Font.Medium
            font.family: theme.typography.fontFamily
            color: theme.colors.textPrimary
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Cross-dissolves, wipes, and motion blends will appear here. This build lists common presets for reference.")
            font.pixelSize: theme.typography.caption
            font.family: theme.typography.fontFamily
            color: theme.colors.textSecondary
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: [
                qsTr("Cross Dissolve — 0.5s"),
                qsTr("Dip to Black — 0.75s"),
                qsTr("Push — Left"),
                qsTr("Slide — Up"),
                qsTr("Radial Wipe")
            ]

            delegate: Rectangle {
                required property string modelData
                width: ListView.view.width
                height: 40
                radius: 6
                color: delMa.containsMouse ? theme.colors.panelElevated : theme.colors.secondaryPanel
                border.color: theme.colors.borderHairline
                border.width: 1

                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    text: modelData
                    font.pixelSize: theme.typography.body
                    font.family: theme.typography.fontFamily
                    color: theme.colors.textPrimary
                }

                MouseArea {
                    id: delMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { color: theme.colors.scrollbar; radius: 2 }
            }
        }
    }
}
