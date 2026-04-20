import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

/**
 * After Effects–style effect stack for the selected timeline clip.
 * Data: mainWindow.selectedClipEffects (see MainWindow.cpp).
 */
Rectangle {
    id: root
    color: theme.colors.panelBackground
    border.width: embedded ? 0 : 1
    border.color: theme.colors.borderColor
    clip: true

    /** Timeline dock: no outer border, tighter chrome */
    property bool embedded: false
    /** Compact top spacing when embedded inside timeline dock */
    property bool compact: false
    /** Optional large header (right dock) */
    property bool showHeader: true
    property string headerTitle: qsTr("Effect Controls")

    Theme { id: theme }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: compact ? 4 : (embedded ? 0 : 10)
        spacing: compact ? 4 : 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: showHeader ? 36 : 0
            visible: showHeader
            color: theme.colors.secondaryPanel
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                Label {
                    text: root.headerTitle
                    color: theme.colors.textPrimary
                    font.pixelSize: theme.typography.body
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }
                Label {
                    text: mainWindow && mainWindow.selectedClipId.length > 0
                          ? mainWindow.selectedClipId : qsTr("No clip")
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.caption
                    elide: Text.ElideRight
                    Layout.maximumWidth: 180
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderColor
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            ComboBox {
                id: fxPick
                Layout.fillWidth: true
                implicitHeight: 26
                enabled: mainWindow && mainWindow.selectedClipId.length > 0 && mainWindow.registryEffectCount > 0
                model: mainWindow ? mainWindow.effectChoicesFlat : []
                textRole: "name"
                valueRole: "id"
                font.pixelSize: theme.typography.caption
                background: Rectangle {
                    color: theme.colors.elevated
                    border.color: theme.colors.borderColor
                    radius: 0
                }
                contentItem: Text {
                    leftPadding: 8
                    text: fxPick.displayText
                    color: theme.colors.textPrimary
                    font: fxPick.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
            Button {
                text: qsTr("Add")
                implicitHeight: 26
                enabled: fxPick.enabled && fxPick.currentIndex >= 0
                onClicked: {
                    if (!mainWindow || fxPick.currentIndex < 0)
                        return
                    const row = mainWindow.effectChoicesFlat[fxPick.currentIndex]
                    if (row && row.id)
                        mainWindow.addEffectToSelectedClip(row.id)
                }
                background: Rectangle {
                    color: parent.enabled && parent.hovered ? theme.colors.borderMedium : theme.colors.elevated
                    border.color: theme.colors.borderColor
                    radius: 0
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? theme.colors.textPrimary : theme.colors.textDisabled
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: theme.typography.caption
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                background: Rectangle { color: theme.colors.borderSubtle; radius: 0 }
                contentItem: Rectangle { implicitWidth: 6; color: theme.colors.scrollbar; radius: 0 }
            }

            Column {
                width: parent.width
                spacing: 0

                Repeater {
                    model: mainWindow ? mainWindow.selectedClipEffects : []

                    delegate: Column {
                        id: fxBlock
                        width: parent.width
                        spacing: 0
                        required property int index
                        required property var modelData
                        property var fx: modelData

                        Rectangle {
                            width: parent.width
                            height: 30
                            color: rowMA.containsMouse ? theme.colors.tertiaryPanel : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 6

                                Label {
                                    text: fxBlock.fx.expanded ? theme.icons.expand : theme.icons.collapse
                                    color: theme.colors.textDisabled
                                    font.pixelSize: 9
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mainWindow.setEffectExpandedOnSelectedClip(fxBlock.index, !fxBlock.fx.expanded)
                                    }
                                }
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 0
                                    color: fxBlock.fx.enabled ? theme.colors.borderMedium : "transparent"
                                    border.width: 1
                                    border.color: theme.colors.borderColor
                                    Label {
                                        anchors.centerIn: parent
                                        visible: fxBlock.fx.enabled
                                        text: "\u2713"
                                        font.pixelSize: 8
                                        color: theme.colors.textPrimary
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mainWindow.setEffectEnabledOnSelectedClip(fxBlock.index, !fxBlock.fx.enabled)
                                    }
                                }
                                Label {
                                    text: fxBlock.fx.displayName !== undefined ? fxBlock.fx.displayName : fxBlock.fx.effectId
                                    color: fxBlock.fx.enabled ? theme.colors.textPrimary : theme.colors.textDisabled
                                    font.pixelSize: theme.typography.caption
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Label {
                                    text: "\u2715"
                                    color: rmMA.containsMouse ? theme.colors.textPrimary : theme.colors.textDisabled
                                    font.pixelSize: 10
                                    MouseArea {
                                        id: rmMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mainWindow.removeEffectOnSelectedClip(fxBlock.index)
                                    }
                                }
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: theme.colors.borderSubtle
                            }
                            MouseArea {
                                id: rowMA
                                anchors.fill: parent
                                anchors.rightMargin: 36
                                hoverEnabled: true
                                onClicked: mainWindow.setEffectExpandedOnSelectedClip(fxBlock.index, !fxBlock.fx.expanded)
                            }
                        }

                        Rectangle {
                            visible: fxBlock.fx.expanded === true
                            width: parent.width
                            height: visible ? innerCol.implicitHeight + 10 : 0
                            color: theme.colors.timelineBackground
                            Column {
                                id: innerCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 6
                                anchors.leftMargin: 28
                                spacing: 4

                                Repeater {
                                    model: fxBlock.fx.parameterRows || []

                                    delegate: RowLayout {
                                        id: paramRow
                                        width: fxBlock.width - 36
                                        spacing: 6
                                        required property var modelData
                                        visible: typeof modelData.value === "number"

                                        Label {
                                            text: modelData.label !== undefined ? modelData.label : modelData.key
                                            color: theme.colors.textSecondary
                                            font.pixelSize: theme.typography.micro
                                            Layout.preferredWidth: 100
                                            elide: Text.ElideRight
                                        }
                                        Slider {
                                            id: pSl
                                            Layout.fillWidth: true
                                            from: modelData.min !== undefined ? modelData.min : 0
                                            to: modelData.max !== undefined ? modelData.max : 1
                                            value: modelData.value !== undefined ? modelData.value : 0
                                            onValueChanged: {
                                                if (pressed && mainWindow) {
                                                    const k = modelData.key !== undefined ? modelData.key : ""
                                                    if (k.length > 0)
                                                        mainWindow.setSelectedClipEffectParameter(fxBlock.index, k, value)
                                                }
                                            }
                                            background: Rectangle {
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                width: parent.availableWidth
                                                height: 3
                                                color: theme.colors.borderColor
                                                radius: 0
                                                Rectangle {
                                                    width: parent.parent.visualPosition * parent.width
                                                    height: parent.height
                                                    color: theme.colors.borderMedium
                                                    radius: 0
                                                }
                                            }
                                            handle: Rectangle {
                                                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                                width: 10
                                                height: 10
                                                radius: 0
                                                color: theme.colors.textSecondary
                                                border.width: 1
                                                border.color: theme.colors.borderColor
                                            }
                                        }
                                        Label {
                                            text: Number(pSl.value).toFixed(3)
                                            color: theme.colors.textSecondary
                                            font.pixelSize: theme.typography.micro
                                            font.family: "Consolas"
                                            Layout.preferredWidth: 52
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    width: parent.width
                    visible: !mainWindow || mainWindow.selectedClipId.length === 0
                    topPadding: 20
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Select a clip on the timeline to edit effects.")
                    wrapMode: Text.WordWrap
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.caption
                }

                Label {
                    width: parent.width
                    visible: mainWindow && mainWindow.selectedClipId.length > 0 && mainWindow.selectedClipEffects.length === 0
                    topPadding: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("No effects on this clip. Choose an effect and press Add.")
                    wrapMode: Text.WordWrap
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.caption
                }
            }
        }
    }
}
