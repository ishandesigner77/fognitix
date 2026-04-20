import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Item {
    id: root

    property string trackId: ""
    property string trackName: "Track"
    property string trackType: "video"
    property int    trackIndex: 0
    property int    trackRowHeight: 48
    property string labelColorHex: ""
    property string clipsJson: "[]"
    property real   pixelsPerSec: 80.0
    property real   zoomLevel: 1.0
    property real   viewOffset: 0.0
    property bool   trackVisible: true
    property bool   trackLocked: false
    property bool   trackSolo: false
    property bool   trackMuted: false
    property bool   expanded: false

    readonly property int headerWidth: 80
    readonly property int rowH: Math.max(30, Math.min(200, trackRowHeight))

    Theme { id: theme }

    height: expanded ? rowH + 96 : rowH

    Behavior on height { NumberAnimation { duration: theme.animations.fast } }

    readonly property color typeColor: {
        switch (trackType) {
            case "audio":      return theme.colors.trackAudio
            case "text":       return theme.colors.trackText
            case "adjustment": return theme.colors.trackAdj
            default:           return theme.colors.trackVideo
        }
    }

    readonly property color labelStripeColor: {
        if (labelColorHex && labelColorHex.length > 0) {
            return labelColorHex
        }
        return typeColor
    }

    property var clipList: []

    onClipsJsonChanged: {
        try {
            clipList = JSON.parse(clipsJson || "[]")
        } catch (e) {
            clipList = []
        }
    }
    Component.onCompleted: {
        try {
            clipList = JSON.parse(clipsJson || "[]")
        } catch (e) {
            clipList = []
        }
    }

    Row {
        anchors.fill: parent

        Rectangle {
            id: header
            width: root.headerWidth
            height: root.rowH
            color: theme.colors.secondaryPanel
            border.color: theme.colors.borderSubtle

            Row {
                anchors.fill: parent
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                anchors.topMargin: 2
                anchors.bottomMargin: 5
                spacing: 2

                Rectangle {
                    id: labelStripe
                    width: 5
                    height: parent.height
                    radius: 0
                    color: root.labelStripeColor

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton)
                                labelMenu.popup()
                        }
                    }

                    Menu {
                        id: labelMenu
                        title: qsTr("Track label")
                        MenuItem {
                            text: qsTr("Blue")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, theme.colors.accent.toString())
                        }
                        MenuItem {
                            text: qsTr("Green")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, "#7a8470")
                        }
                        MenuItem {
                            text: qsTr("Purple")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, theme.colors.accent.toString())
                        }
                        MenuItem {
                            text: qsTr("Orange")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, "#a8956a")
                        }
                        MenuItem {
                            text: qsTr("Red")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, "#9a6a5e")
                        }
                        MenuItem {
                            text: qsTr("Default")
                            onTriggered: if (mainWindow) mainWindow.setTrackLabelColor(root.trackId, "")
                        }
                    }
                }

                Column {
                    width: parent.width - labelStripe.width - parent.spacing
                    height: parent.height
                    spacing: 1

                    Row {
                        width: parent.width
                        height: Math.max(14, (parent.height - 18) / 2)
                        spacing: 2

                        Label {
                            width: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.expanded ? theme.icons.expand : theme.icons.collapse
                            color: theme.colors.textMuted
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.expanded = !root.expanded
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Label {
                            width: parent.width - 12 - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.trackName
                            color: theme.colors.textMuted
                            font.pixelSize: 12
                            font.family: theme.typography.fontFamily
                            elide: Text.ElideRight
                        }
                    }

                    Row {
                        width: parent.width
                        height: 18
                        spacing: 1

                        ToolButton {
                            id: visBtn
                            width: 22
                            height: 18
                            checkable: true
                            checked: root.trackVisible
                            text: root.trackVisible ? "\uD83D\uDC41" : "\u2012"
                            font.pixelSize: 9
                            ToolTip.text: qsTr("Toggle visibility")
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            onCheckedChanged: root.trackVisible = checked
                            background: Rectangle { color: "transparent" }
                            contentItem: Text {
                                text: visBtn.text
                                font: visBtn.font
                                color: root.trackVisible ? theme.colors.textSecondary : theme.colors.textDisabled
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        ToolButton {
                            id: muteBtn
                            width: 22
                            height: 18
                            checkable: true
                            checked: root.trackMuted
                            text: "M"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            ToolTip.text: qsTr("Mute track")
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            onCheckedChanged: root.trackMuted = checked
                            background: Rectangle {
                                color: muteBtn.checked ? "#6a2a0a" : "transparent"
                                radius: 2
                            }
                            contentItem: Text {
                                text: muteBtn.text
                                font: muteBtn.font
                                color: muteBtn.checked ? "#ff8040" : theme.colors.textDisabled
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        ToolButton {
                            id: lockBtn
                            width: 22
                            height: 18
                            checkable: true
                            checked: root.trackLocked
                            text: theme.icons.lock
                            font.pixelSize: 9
                            ToolTip.text: qsTr("Lock track")
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            onCheckedChanged: root.trackLocked = checked
                            background: Rectangle { color: "transparent" }
                            contentItem: Text {
                                text: lockBtn.text
                                font: lockBtn.font
                                color: root.trackLocked ? theme.colors.warning : theme.colors.textDisabled
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                width: 1; height: parent.height
                color: theme.colors.borderColor
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderSubtle
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                propagateComposedEvents: true
                onDoubleClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton && mainWindow)
                        mainWindow.resetTrackHeightPx(root.trackId)
                }
            }

            Rectangle {
                id: heightDrag
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 5
                color: dragMA.containsMouse ? theme.colors.accent : "transparent"

                MouseArea {
                    id: dragMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeVerCursor
                    property int startY: 0
                    property int startH: 0
                    onPressed: (mouse) => {
                        startY = mouse.y
                        startH = root.rowH
                    }
                    onPositionChanged: (mouse) => {
                        if (pressed && mainWindow) {
                            const dy = mouse.y - startY
                            mainWindow.setTrackHeightPx(root.trackId, startH + dy)
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width - root.headerWidth
            height: root.rowH
            clip: true

            Rectangle {
                anchors.fill: parent
                color: root.trackIndex % 2 === 0 ? theme.colors.trackRowEven
                                                 : theme.colors.trackRowOdd
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1
                    color: theme.colors.borderMid
                }
            }

            Repeater {
                model: root.clipList.length

                TimelineClipView {
                    required property int index
                    readonly property var clip: root.clipList[index]
                    x: ((clip.start !== undefined ? clip.start : 0) - root.viewOffset) * root.pixelsPerSec * root.zoomLevel
                    height: parent.height
                    trackId: root.trackId
                    clipId: clip.clipId !== undefined ? clip.clipId : ""
                    clipName: clip.displayName || clip.fileName || clip.mediaId || "Clip"
                    clipDur: clip.duration !== undefined ? clip.duration : 1
                    clipSourceIn: clip.sourceIn !== undefined ? clip.sourceIn : 0
                    pixelsPerSec: root.pixelsPerSec
                    zoomLevel: root.zoomLevel
                    clipColor: root.typeColor
                    clipBg: theme.colors.clipVideoBot
                    isAudioClip: root.trackType === "audio"
                    mediaId: clip.mediaId || ""
                    mediaPath: clip.mediaPath || ""
                    selected: mainWindow && clip.clipId && mainWindow.selectedClipId === clip.clipId
                              && mainWindow.selectedTrackId === root.trackId
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderSubtle
            }
        }
    }

    Rectangle {
        visible: root.expanded
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 96
        color: "#080810"
        border.color: theme.colors.borderSubtle

        Label {
            anchors.centerIn: parent
            text: qsTr("Keyframe graph")
            color: theme.colors.textDisabled
            font.pixelSize: theme.typography.caption
        }
    }
}
