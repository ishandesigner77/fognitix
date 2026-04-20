import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root

    property int currentIndex: 0
    property var tabLabels: []

    signal tabClicked(int index)

    Theme { id: theme }

    implicitHeight: 36
    color: theme.colors.secondaryPanel

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.tabLabels

            delegate: Rectangle {
                required property int index
                required property string modelData

                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.currentIndex === index ? theme.colors.panelElevated : "transparent"

                Label {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: theme.typography.caption
                    font.weight: root.currentIndex === index ? Font.Medium : Font.Normal
                    font.family: theme.typography.fontFamily
                    color: root.currentIndex === index ? theme.colors.textMain : theme.colors.textSecondary
                }

                Rectangle {
                    visible: root.currentIndex === index
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.45
                    height: 2
                    radius: 1
                    color: theme.colors.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index
                        root.tabClicked(index)
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: theme.colors.borderHairline
    }
}
