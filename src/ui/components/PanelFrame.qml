import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    Theme { id: theme }

    property string title: ""
    property alias body: bodyLoader.sourceComponent
    property bool showDockButton: false
    property var onDockFn: null

    color: theme.colors.panelBg
    border.color: theme.colors.borderSubtle
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surfaceRaised

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderSubtle
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8

                Text {
                    text: root.title
                    color: theme.colors.textSecondary
                    font.pixelSize: 11
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                ToolButton {
                    visible: root.showDockButton
                    text: qsTr("Dock")
                    onClicked: if (typeof root.onDockFn === "function") root.onDockFn()
                }
            }
        }

        Loader {
            id: bodyLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
