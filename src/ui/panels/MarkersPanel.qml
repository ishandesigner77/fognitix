import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground
    Theme { id: theme }

    readonly property var markerColors: [
        { name: "Blue",   hex: "#d4c9b0" },
        { name: "Red",    hex: "#9a6a5e" },
        { name: "Orange", hex: "#a8956a" },
        { name: "Yellow", hex: "#f59e0b" },
        { name: "Green",  hex: "#7a8470" },
        { name: "Purple", hex: "#d4c9b0" },
        { name: "Pink",   hex: "#ec4899" },
        { name: "White",  hex: "#e8e8ea" }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.secondaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 6

                Label {
                    text: qsTr("MARKERS")
                    color: theme.colors.textDisabled
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }

                // Add marker
                ToolButton {
                    implicitWidth: 24; implicitHeight: 24
                    text: "+"
                    font.pixelSize: 14; font.weight: Font.Bold
                    ToolTip.text: qsTr("Add marker at playhead (M)")
                    ToolTip.visible: hovered; ToolTip.delay: 600
                    background: Rectangle { color: parent.hovered ? theme.colors.elevated : "transparent"; radius: 4 }
                    contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: if (mainWindow) mainWindow.addMarkerAtPlayhead()
                }

                // Clear all
                ToolButton {
                    implicitWidth: 24; implicitHeight: 24
                    text: "\u2715"
                    font.pixelSize: 11
                    ToolTip.text: qsTr("Clear all markers")
                    ToolTip.visible: hovered; ToolTip.delay: 600
                    background: Rectangle { color: parent.hovered ? theme.colors.elevated : "transparent"; radius: 4 }
                    contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: if (appState) appState.clearMarkers()
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
        }

        // Color filter chips
        Rectangle {
            Layout.fillWidth: true
            height: 34
            color: theme.colors.panelBackground

            property string filterColor: ""

            ListView {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                orientation: ListView.Horizontal
                spacing: 4
                clip: true

                model: [{ name: "All", hex: "" }].concat(root.markerColors)

                delegate: Rectangle {
                    height: 22
                    width: chipLbl.implicitWidth + 16
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    radius: 11
                    color: {
                        if (modelData.hex === "") return fMA.containsMouse ? theme.colors.elevated : theme.colors.tertiaryPanel
                        return modelData.hex + "33"
                    }
                    border.color: modelData.hex === "" ? theme.colors.borderColor : modelData.hex

                    Label {
                        id: chipLbl
                        anchors.centerIn: parent
                        text: modelData.name
                        color: modelData.hex === "" ? theme.colors.textSecondary : modelData.hex
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: fMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.parent.parent.parent.filterColor = modelData.hex
                    }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle }
        }

        // Markers list
        ListView {
            id: markerList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 1
            model: appState ? appState.markers : []

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { color: theme.colors.scrollbar; radius: 3; implicitWidth: 6 }
                background: Rectangle { color: "transparent" }
            }

            delegate: Rectangle {
                id: mRow
                width: markerList.width
                height: editMode ? 82 : 46
                color: mMA.containsMouse ? theme.colors.secondaryPanel : "transparent"
                Behavior on height { NumberAnimation { duration: 120 } }

                property bool editMode: false

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
                    spacing: 8
                    visible: !mRow.editMode

                    // Color dot
                    Rectangle {
                        width: 10; height: 10; radius: 5
                        color: modelData.color || "#d4c9b0"
                    }

                    // Timecode
                    Label {
                        text: {
                            const s = modelData.time
                            const h = Math.floor(s / 3600)
                            const m = Math.floor((s % 3600) / 60)
                            const ss = Math.floor(s % 60)
                            const fr = Math.floor((s % 1) * 30)
                            return String(h).padStart(2,"0")+":"+String(m).padStart(2,"0")+":"+String(ss).padStart(2,"0")+":"+String(fr).padStart(2,"0")
                        }
                        color: theme.colors.textPrimary
                        font.pixelSize: 11; font.family: "Consolas"
                        Layout.preferredWidth: 80
                    }

                    Label {
                        text: modelData.name || qsTr("Marker")
                        color: theme.colors.textPrimary
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Jump to
                    ToolButton {
                        implicitWidth: 22; implicitHeight: 22
                        text: "\u25B6"
                        font.pixelSize: 10
                        background: Rectangle { color: parent.hovered ? theme.colors.accentMuted : "transparent"; radius: 3 }
                        contentItem: Text { text: parent.text; color: theme.colors.accent; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: if (mainWindow) mainWindow.seek(modelData.time)
                    }

                    // Edit
                    ToolButton {
                        implicitWidth: 22; implicitHeight: 22
                        text: "\u270E"
                        font.pixelSize: 11
                        background: Rectangle { color: parent.hovered ? theme.colors.elevated : "transparent"; radius: 3 }
                        contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: mRow.editMode = true
                    }

                    // Delete
                    ToolButton {
                        implicitWidth: 22; implicitHeight: 22
                        text: "\u2715"
                        font.pixelSize: 11
                        background: Rectangle { color: parent.hovered ? "#3a1a1a" : "transparent"; radius: 3 }
                        contentItem: Text { text: parent.text; color: theme.colors.danger; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: if (appState) appState.removeMarkerAt(index)
                    }
                }

                // Inline edit
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    visible: mRow.editMode

                    TextField {
                        id: nameEdit
                        Layout.fillWidth: true
                        height: 24
                        text: modelData ? (modelData.name || "") : ""
                        placeholderText: qsTr("Marker name")
                        color: theme.colors.textPrimary
                        font.pixelSize: 12
                        leftPadding: 8
                        background: Rectangle { color: theme.colors.elevated; border.color: theme.colors.borderFocus; radius: 4 }
                    }

                    // Color picker row
                    RowLayout {
                        spacing: 4
                        Repeater {
                            model: root.markerColors
                            delegate: Rectangle {
                                width: 16; height: 16; radius: 8
                                color: modelData.hex
                                border.color: nameEdit.parent.parent.currentColor === modelData.hex ? "#fff" : "transparent"
                                border.width: 2
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: nameEdit.parent.parent.currentColor = modelData.hex
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: qsTr("Save")
                            implicitHeight: 22; font.pixelSize: 11
                            background: Rectangle { color: parent.hovered ? theme.colors.accentHover : theme.colors.accent; radius: 4 }
                            contentItem: Text { text: parent.text; color: "#fff"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                if (appState) appState.updateMarker(index, nameEdit.text, nameEdit.parent.parent.currentColor, "")
                                mRow.editMode = false
                            }
                        }
                        Button {
                            text: qsTr("Cancel")
                            implicitHeight: 22; font.pixelSize: 11
                            background: Rectangle { color: parent.hovered ? theme.colors.elevated : theme.colors.secondaryPanel; border.color: theme.colors.borderColor; radius: 4 }
                            contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: mRow.editMode = false
                        }
                    }

                    property string currentColor: modelData ? (modelData.color || "#d4c9b0") : "#d4c9b0"
                }

                MouseArea {
                    id: mMA
                    anchors.fill: parent
                    hoverEnabled: true
                    visible: !mRow.editMode
                    onDoubleClicked: if (mainWindow) mainWindow.seek(modelData.time)
                }

                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle; opacity: 0.4 }
            }

            Label {
                anchors.centerIn: parent
                visible: markerList.count === 0
                text: qsTr("No markers yet\nPress M to add one at the playhead")
                color: theme.colors.textDisabled
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
