import QtQuick
import QtQuick.Controls
import Fognitix

Item {
    id: root

    property string clipId:       ""
    property string trackId:      ""
    property string clipName:     "Clip"
    property color  clipColor:    theme.colors.clipVideo
    property color  clipBg:       theme.colors.clipVideoBot
    property real   clipDur:      5.0
    property real   clipSourceIn: 0.0
    property real   pixelsPerSec: 80.0
    property real   zoomLevel:    1.0
    property bool   selected:     false
    property bool   isAudioClip:  false
    property string mediaId:      ""
    property string mediaPath:    ""

    Theme { id: theme }

    width:  Math.max(2, clipDur * pixelsPerSec * zoomLevel)
    height: parent ? parent.height : 48

    readonly property int thumbCols: Math.max(1, Math.floor(clipRect.width / 56))

    Gradient {
        id: gradVideo
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: theme.colors.clipVideoTop }
        GradientStop { position: 1.0; color: theme.colors.clipVideoBot }
    }

    Item {
        id: clipWrap
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        anchors.leftMargin:  1
        anchors.rightMargin: 1

        Rectangle {
            id: selectionGlow
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            radius: 6
            visible: root.selected
            color: theme.colors.primary
            opacity: 0.35
        }

        Rectangle {
            id: clipRect
            anchors.fill: parent
            radius: 4
            clip: true

        color: root.isAudioClip ? theme.colors.clipAudioFill : "transparent"
        border.color: root.selected ? theme.colors.primary : theme.colors.borderSubtle
        border.width: 1
        gradient: root.isAudioClip ? null : gradVideo

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "#00000000"
            border.color: "#ffffff"
            border.width: 1
            opacity: (root.selected ? 0.14 : 0.05) + (clipMA.containsMouse ? 0.06 : 0)
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }

        Rectangle {
            id: stripe
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            color: root.clipColor
        }

        Image {
            id: waveImg
            visible: root.isAudioClip && root.mediaId.length > 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: stripe.bottom
            anchors.bottom: labelArea.top
            anchors.margins: 2
            fillMode: Image.Stretch
            asynchronous: true
            cache: false
            opacity: 0.7
            source: {
                if (!root.isAudioClip || root.mediaId.length === 0) return ""
                const w = Math.max(32, Math.floor(width))
                const h = Math.max(16, Math.floor(height))
                return "image://fognitixWave/" + root.mediaId + "|" + root.clipSourceIn + "|"
                        + root.clipDur + "|" + w + "|" + h
            }
        }

        Row {
            id: filmstrip
            visible: !root.isAudioClip && root.mediaId.length > 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: stripe.bottom
            anchors.bottom: labelArea.top
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            spacing: 1

            Repeater {
                model: root.thumbCols
                delegate: Image {
                    required property int index
                    property real tsec: root.clipSourceIn + ((index + 0.5) / root.thumbCols) * root.clipDur
                    width: Math.max(18, (filmstrip.width - (root.thumbCols - 1) * filmstrip.spacing) / root.thumbCols)
                    height: filmstrip.height
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    source: "image://fognitixThumb/" + root.mediaId + "|" + tsec + "|72|42"
                }
            }
        }

        Rectangle {
            id: labelArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.min(20, parent.height * 0.45)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#aa000000" }
            }
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            text: root.clipName
            color: theme.colors.textMain
            font.pixelSize: theme.typography.caption
            font.family: theme.typography.fontFamily
            elide: Text.ElideRight
            z: 2
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 5
            color: leftMA.containsMouse ? theme.colors.primary : "transparent"
            radius: 2
            z: 3
            MouseArea {
                id: leftMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeHorCursor
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 5
            color: rightMA.containsMouse ? theme.colors.primary : "transparent"
            radius: 2
            z: 3
            MouseArea {
                id: rightMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeHorCursor
            }
        }

        Rectangle {
            anchors.fill: parent
            color: clipMA.containsMouse ? "#ffffff" : "transparent"
            opacity: 0.05
            radius: parent.radius
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: clipMA
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (mainWindow && root.clipId.length > 0 && root.trackId.length > 0)
                    mainWindow.selectTimelineClip(root.trackId, root.clipId)
            }
        }
        }
    }
}
