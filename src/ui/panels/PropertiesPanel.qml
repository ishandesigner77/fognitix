import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

    property string selectedLayerName: "No layer selected"
    property string selectedLayerType: "none"

    // Section model
    ListModel {
        id: sections
        ListElement { title: "Transform";   expanded: true  }
        ListElement { title: "Text";        expanded: false }
        ListElement { title: "Mask";        expanded: false }
        ListElement { title: "Effects";     expanded: false }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8

                Label {
                    text: root.selectedLayerName
                    color: theme.colors.textPrimary
                    font.pixelSize: theme.typography.body
                    font.weight: Font.Medium
                    font.family: theme.typography.fontFamily
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: root.selectedLayerType !== "none" ? root.selectedLayerType : ""
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.caption
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderColor
            }
        }

        // ── Properties scroll ─────────────────────────────────────────────
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.contentItem: Rectangle {
                color: theme.colors.scrollbar; radius: 2
            }

            Column {
                width: parent.width
                spacing: 0

                // ── Transform section ────────────────────────────────────
                PropSection {
                    title: qsTr("Transform")
                    width: parent.width

                    Column {
                        width: parent.width
                        spacing: 0

                        PropRow {
                            width: parent.width
                            label: qsTr("Anchor Point")
                            valueText: "960.0, 540.0"
                            hasKeyframe: true
                        }
                        PropRow {
                            width: parent.width
                            label: qsTr("Position")
                            valueText: "960.0, 540.0"
                            hasKeyframe: false
                        }
                        PropRow {
                            width: parent.width
                            label: qsTr("Scale")
                            valueText: "100.0%"
                            hasKeyframe: false
                        }
                        PropRow {
                            width: parent.width
                            label: qsTr("Rotation")
                            valueText: "0.0°"
                            hasKeyframe: false
                        }
                        PropRow {
                            width: parent.width
                            label: qsTr("Opacity")
                            valueText: "100%"
                            hasKeyframe: false
                            isSlider: true
                            sliderValue: 1.0
                        }
                    }
                }

                // ── Text section ─────────────────────────────────────────
                PropSection {
                    title: qsTr("Text")
                    width: parent.width
                    initialExpanded: false

                    Column {
                        width: parent.width
                        spacing: 0

                        PropRow { width: parent.width; label: qsTr("Font Size");   valueText: "72 px" }
                        PropRow { width: parent.width; label: qsTr("Tracking");    valueText: "0"     }
                        PropRow { width: parent.width; label: qsTr("Leading");     valueText: "0"     }
                        PropRow { width: parent.width; label: qsTr("Fill Color");  valueText: "#ffffff"; isColor: true; colorVal: "#ffffff" }
                        PropRow { width: parent.width; label: qsTr("Stroke");      valueText: "Off"   }
                    }
                }

                // ── Mask section ─────────────────────────────────────────
                PropSection {
                    title: qsTr("Masks")
                    width: parent.width
                    initialExpanded: false

                    Item {
                        width: parent.width
                        height: 48
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("No masks — use the Pen tool to add one")
                            color: theme.colors.textDisabled
                            font.pixelSize: theme.typography.caption
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            width: parent.width - 24
                        }
                    }
                }

                // ── Effects stack ─────────────────────────────────────────
                PropSection {
                    title: qsTr("Effects")
                    width: parent.width
                    initialExpanded: false

                    Item {
                        width: parent.width
                        height: 48
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("No effects — drag from the Effects browser")
                            color: theme.colors.textDisabled
                            font.pixelSize: theme.typography.caption
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            width: parent.width - 24
                        }
                    }
                }
            }
        }
    }

    // Inline component: collapsible section
    component PropSection: Column {
        id: propSec
        property string title: ""
        property bool initialExpanded: true
        default property alias content: contentWrapper.children

        width: parent.width
        spacing: 0

        property bool _expanded: initialExpanded

        // Section header
        Rectangle {
            width: parent.width
            height: 28
            color: theme.colors.tertiaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Label {
                    text: propSec._expanded ? theme.icons.expand : theme.icons.collapse
                    color: theme.colors.textDisabled
                    font.pixelSize: 9
                }

                Label {
                    text: propSec.title
                    color: theme.colors.textSecondary
                    font.pixelSize: theme.typography.caption
                    font.weight: Font.Medium
                    font.letterSpacing: 0.3
                    Layout.fillWidth: true
                }

                // Add button
                Label {
                    text: "\u002B"
                    color: theme.colors.textDisabled
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = theme.colors.textSecondary
                        onExited:  parent.color = theme.colors.textDisabled
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: propSec._expanded = !propSec._expanded
                cursorShape: Qt.PointingHandCursor
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderSubtle
            }
        }

        // Content wrapper
        Item {
            id: contentWrapper
            width: parent.width
            height: propSec._expanded ? implicitHeight : 0
            visible: propSec._expanded
            implicitHeight: childrenRect.height
            clip: true
            Behavior on height { NumberAnimation { duration: theme.animations.fast } }
        }
    }

    // Inline component: property row
    component PropRow: Item {
        id: propRow
        property string label: ""
        property string valueText: ""
        property bool hasKeyframe: false
        property bool isSlider: false
        property bool isColor: false
        property real sliderValue: 0.5
        property color colorVal: "#cccccc"

        height: 30

        Rectangle {
            anchors.fill: parent
            color: rowMA.containsMouse ? theme.colors.tertiaryPanel : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 6

                // Keyframe toggle dot
                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: propRow.hasKeyframe ? theme.colors.keyframe : "transparent"
                    border.color: propRow.hasKeyframe ? theme.colors.keyframe : theme.colors.textDisabled
                    border.width: 1
                    MouseArea {
                        anchors.fill: parent
                        onClicked: propRow.hasKeyframe = !propRow.hasKeyframe
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Label
                Label {
                    text: propRow.label
                    color: theme.colors.textSecondary
                    font.pixelSize: theme.typography.body
                    font.family: theme.typography.fontFamily
                    Layout.preferredWidth: 100
                    elide: Text.ElideRight
                }

                // Value / slider / color
                Item {
                    Layout.fillWidth: true
                    height: parent.height

                    // Text value
                    Label {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !propRow.isSlider && !propRow.isColor
                        text: propRow.valueText
                        color: theme.colors.textPrimary
                        font.pixelSize: theme.typography.body
                        font.family: "Consolas"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.SizeHorCursor
                        }
                    }

                    // Slider
                    Slider {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: propRow.isSlider
                        width: 90
                        from: 0; to: 1; value: propRow.sliderValue
                        background: Rectangle {
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth; height: 3
                            color: theme.colors.borderColor; radius: 2
                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height; color: theme.colors.accent; radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 10; height: 10; radius: 5
                            color: theme.colors.accent
                        }
                    }

                    // Color swatch
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: propRow.isColor
                        width: 40; height: 18; radius: 3
                        color: propRow.colorVal
                        border.color: theme.colors.borderColor
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderSubtle
                opacity: 0.5
            }

            MouseArea {
                id: rowMA
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
