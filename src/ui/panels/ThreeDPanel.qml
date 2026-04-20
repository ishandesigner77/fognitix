import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property bool uniformScale: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surfaceRaised
            border.width: 1
            border.color: theme.colors.borderSoft

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: theme.spacing.md
                text: "3D TRANSFORM"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 0

                // POSITION
                PropGroupHeader { label: "POSITION" }
                XYZRow { labelX: "X"; labelY: "Y"; labelZ: "Z"; defaultValue: 0; unit: "px" }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // ROTATION
                PropGroupHeader { label: "ROTATION" }
                XYZRow { labelX: "X"; labelY: "Y"; labelZ: "Z"; defaultValue: 0; unit: "\u00B0" }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // SCALE
                PropGroupHeader { label: "SCALE" }
                XYZRow { labelX: "X"; labelY: "Y"; labelZ: "Z"; defaultValue: 100; unit: "%" }

                // Uniform scale checkbox
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: theme.spacing.md + 22
                    Layout.rightMargin: theme.spacing.md
                    Layout.bottomMargin: theme.spacing.sm

                    CheckBox {
                        id: uniformScaleCb
                        text: "Uniform Scale"
                        font.pixelSize: theme.typography.small
                        onCheckedChanged: root.uniformScale = checked
                        contentItem: Text {
                            leftPadding: uniformScaleCb.indicator.width + 6
                            text: uniformScaleCb.text; font: uniformScaleCb.font
                            color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // ANCHOR POINT
                PropGroupHeader { label: "ANCHOR POINT" }
                XYZRow { labelX: "X"; labelY: "Y"; labelZ: "Z"; defaultValue: 0; unit: "px" }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSoft }

                // Reset All button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: theme.spacing.md
                    height: 28
                    color: resetMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    Text { anchors.centerIn: parent; text: "Reset All"; font.pixelSize: theme.typography.small; color: theme.colors.textPrimary }
                    MouseArea { id: resetMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    component PropGroupHeader: Rectangle {
        property string label: ""

        Layout.fillWidth: true
        height: 26
        color: theme.colors.surface
        border.width: 1
        border.color: theme.colors.borderSoft

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: theme.spacing.md
            text: parent.label
            font.pixelSize: theme.typography.micro
            font.letterSpacing: 0.6
            font.weight: Font.Medium
            color: theme.colors.textMuted
        }
    }

    component XYZRow: RowLayout {
        property string labelX: "X"
        property string labelY: "Y"
        property string labelZ: "Z"
        property real defaultValue: 0
        property string unit: ""

        Layout.fillWidth: true
        Layout.leftMargin: theme.spacing.sm
        Layout.rightMargin: theme.spacing.sm
        Layout.topMargin: theme.spacing.xs
        Layout.bottomMargin: theme.spacing.xs
        spacing: theme.spacing.xs

        // Keyframe stopwatch
        Rectangle {
            width: 14; height: 14; radius: 7
            color: "transparent"
            border.width: 1; border.color: theme.colors.textDim

            Rectangle {
                anchors.centerIn: parent
                width: 4; height: 4; radius: 2
                color: theme.colors.textDim
            }

            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
        }

        Repeater {
            model: [labelX, labelY, labelZ]

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: modelData
                    font.pixelSize: theme.typography.small
                    color: modelData === "X" ? "#cc6666" : (modelData === "Y" ? "#66cc66" : "#6688cc")
                    Layout.preferredWidth: 10
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: spinMa.containsMouse ? theme.colors.surfaceHover : theme.colors.surface
                    border.width: 1; border.color: theme.colors.borderSoft
                    radius: 2

                    TextInput {
                        anchors.fill: parent; anchors.margins: 4
                        text: parent.parent.parent.parent.defaultValue.toString()
                        font.pixelSize: theme.typography.small
                        color: theme.colors.textPrimary
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true
                    }

                    MouseArea {
                        id: spinMa
                        anchors.fill: parent
                        hoverEnabled: true
                        // drag for scrubbing
                        cursorShape: Qt.SizeHorCursor
                    }
                }
            }
        }

        Text {
            text: unit
            font.pixelSize: theme.typography.small
            color: theme.colors.textMuted
            Layout.preferredWidth: 16
        }
    }
}
