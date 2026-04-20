import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

ApplicationWindow {
    id: root
    width: 720
    height: 520
    visible: false
    title: qsTr("Export queue")

    Theme {
        id: theme
    }

    color: theme.colors.windowRoot

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Label {
            text: qsTr("Render queue")
            color: theme.colors.textPrimary
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Use File → Export Media for the full dialog. This window is a compact queue monitor.")
            color: theme.colors.textSecondary
            font.pixelSize: 11
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: theme.colors.secondaryPanel
            border.color: theme.colors.borderSubtle

            Column {
                anchors.centerIn: parent
                spacing: 10
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("No active jobs")
                    color: theme.colors.textDisabled
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }
}
