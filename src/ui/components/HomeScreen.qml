import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: "#d9d9d9"

    signal requestNewProject()
    signal requestOpenProject()
    signal requestContinueLast()
    signal requestEnterWorkspace()
    signal requestOpenRecent(string path)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 16
        color: "#dcdcdc"
        border.color: "#8f8f8f"
        border.width: 1
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 52
                color: "#d5d5d5"
                border.color: "#8f8f8f"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Rectangle {
                        width: 40; height: 40; radius: 6
                        color: "#c4c4c4"
                        border.color: "#8f8f8f"; border.width: 1
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 170; height: 30; radius: 15
                        color: "#c7c7c7"
                        border.color: "#8f8f8f"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Search")
                            color: "#666666"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    Layout.preferredWidth: 185
                    Layout.fillHeight: true
                    color: "#d4d4d4"
                    border.color: "#8f8f8f"; border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Rectangle {
                            width: parent.width - 10
                            height: 34
                            radius: 6
                            color: "#c5c5c5"
                            border.color: "#8f8f8f"; border.width: 1
                            Text { anchors.centerIn: parent; text: qsTr("New Project"); color: "#2d2d2d"; font.pixelSize: 11 }
                            MouseArea { anchors.fill: parent; onClicked: root.requestNewProject() }
                        }
                        Rectangle {
                            width: parent.width - 10
                            height: 34
                            radius: 6
                            color: "#c5c5c5"
                            border.color: "#8f8f8f"; border.width: 1
                            Text { anchors.centerIn: parent; text: qsTr("Open Project"); color: "#2d2d2d"; font.pixelSize: 11 }
                            MouseArea { anchors.fill: parent; onClicked: root.requestOpenProject() }
                        }

                        Item { width: 1; height: 1 }
                        Item { width: 1; height: 1 }
                        Item { width: 1; height: 1 }
                        Item { width: 1; height: 1 }
                        Item { width: 1; height: 1 }
                        Item { width: 1; height: 1 }

                        Rectangle {
                            width: parent.width - 10
                            height: 30
                            radius: 6
                            color: "#c5c5c5"
                            border.color: "#8f8f8f"; border.width: 1
                            Text { anchors.centerIn: parent; text: qsTr("Continue Last"); color: "#2d2d2d"; font.pixelSize: 10 }
                            MouseArea { anchors.fill: parent; onClicked: root.requestContinueLast() }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#dcdcdc"
                    border.color: "#8f8f8f"; border.width: 1

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 56
                        text: qsTr("Welcome To Fognitix")
                        color: "#2b2b2b"
                        font.pixelSize: 44
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }
}
