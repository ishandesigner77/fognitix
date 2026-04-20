import QtQuick
import QtQuick.Controls
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

    property string panelTitle: ""
    property string panelCategory: ""

    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.contentItem: Rectangle {
            implicitWidth: 6
            radius: 3
            color: theme.colors.scrollbar
        }

        Column {
            width: parent.width - 24
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 16
            spacing: 12

            Label {
                text: root.panelTitle.length > 0 ? root.panelTitle : qsTr("Panel")
                color: theme.colors.textPrimary
                font.pixelSize: 15
                font.weight: Font.Medium
                font.family: theme.typography.fontFamily
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Label {
                visible: root.panelCategory.length > 0
                text: root.panelCategory
                color: theme.colors.textDisabled
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 0.8
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: 1
                color: theme.colors.borderSubtle
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Reserved workspace for this tool. Native composition, 2D/3D, HDR, scopes, and audio routing will connect here as the engine exposes each subsystem.")
                color: theme.colors.textSecondary
                font.pixelSize: 12
                font.family: theme.typography.fontFamily
            }
        }
    }
}
