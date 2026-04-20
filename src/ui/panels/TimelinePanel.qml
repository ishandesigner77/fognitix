import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.timelineBackground

    Theme { id: theme }

    property Item editorChrome: null

    ListModel { id: trackModel }
    ListModel { id: miniModel }
    ListModel { id: snapLinesModel }

    function rebuildTracks() {
        trackModel.clear()
        miniModel.clear()
        if (!mainWindow)
            return
        const rows = mainWindow.timelineTracks
        const dur = Math.max(5.0, mainWindow.compositionDuration)
        for (let i = 0; i < rows.length; i++) {
            const r = rows[i]
            trackModel.append({
                trackId: r.trackId,
                trackName: r.trackName,
                trackType: r.trackType,
                trackIndex: r.trackIndex,
                heightPx: r.heightPx,
                labelColor: r.labelColor,
                clipsJson: JSON.stringify(r.clips || [])
            })
            let col = "#2c3542"
            if (r.trackType === "audio")
                col = "#4a5854"
            else if (r.trackType === "text")
                col = "#45424e"
            else if (r.trackType === "adjustment")
                col = "#5a5852"
            const clips = r.clips || []
            for (let j = 0; j < clips.length; j++) {
                const c = clips[j]
                const st = c.start !== undefined ? c.start : 0
                const du = c.duration !== undefined ? c.duration : 1
                miniModel.append({
                    segX: st / dur,
                    segW: Math.max(0.006, du / dur),
                    segColor: col
                })
            }
        }
        root.rebuildSnapLines()
    }

    function rebuildSnapLines() {
        snapLinesModel.clear()
        if (!mainWindow)
            return
        const pps = root.pixelsPerSec * root.zoomLevel
        const vo = root.viewOffset
        const viewW = timelineBody.width - root.headerWidth
        if (viewW <= 0 || pps <= 0)
            return
        const t0 = vo
        const t1 = vo + viewW / pps
        const seen = {}
        function addT(t) {
            if (t < t0 - 0.02 || t > t1 + 0.02)
                return
            const k = Math.round(t * 1000)
            if (seen[k])
                return
            seen[k] = true
            snapLinesModel.append({ tSec: t })
        }
        addT(0)
        for (let s = Math.floor(t0); s <= Math.ceil(t1); s++)
            addT(s)
        const rows = mainWindow.timelineTracks
        for (let i = 0; i < rows.length; i++) {
            const clips = rows[i].clips || []
            for (let j = 0; j < clips.length; j++) {
                const c = clips[j]
                const st = c.start !== undefined ? c.start : 0
                const du = c.duration !== undefined ? c.duration : 1
                addT(st)
                addT(st + du)
            }
        }
    }

    Connections {
        target: mainWindow
        function onTimelineChanged() { root.rebuildTracks() }
    }

    Component.onCompleted: rebuildTracks()

    property real zoomLevel:   1.0
    property real pixelsPerSec: 80.0
    property real viewOffset:   0.0
    readonly property int headerWidth: 80
    property bool _hScrollProgram: false

    function maxTimelineOffset() {
        if (!mainWindow)
            return 0
        const dur = mainWindow.compositionDuration
        const pps = root.pixelsPerSec * root.zoomLevel
        const totalW = dur * pps
        const viewW = timelineBody.width - root.headerWidth
        return Math.max(0, totalW - viewW)
    }

    function applyViewOffsetToHScroll() {
        if (root._hScrollProgram)
            return
        const mo = root.maxTimelineOffset()
        root._hScrollProgram = true
        hScroll.position = mo > 0 ? Math.min(1, Math.max(0, root.viewOffset / mo)) : 0
        root._hScrollProgram = false
    }

    Connections {
        target: root
        function onViewOffsetChanged() {
            root.applyViewOffsetToHScroll()
            root.rebuildSnapLines()
        }
        function onZoomLevelChanged() {
            root.applyViewOffsetToHScroll()
            root.rebuildSnapLines()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: theme.colors.surfaceRaised
            border.color: theme.colors.borderSubtle
            border.width: 0
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderMid
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 12

                TransportControls {}

                Item { Layout.fillWidth: true }

                ToolButton {
                    text: "+ V"
                    font.pixelSize: 11
                    implicitWidth: 36; implicitHeight: 26
                    ToolTip.text: qsTr("Add video track")
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                    onClicked: if (mainWindow) mainWindow.addVideoTrack("V" + (mainWindow.trackCount + 1))
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.trackVideo : theme.colors.elevated
                        border.color: theme.colors.borderColor; radius: 3
                    }
                    contentItem: Text {
                        text: parent.text; font: parent.font
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ToolButton {
                    text: "+ A"
                    font.pixelSize: 11
                    implicitWidth: 36; implicitHeight: 26
                    ToolTip.text: qsTr("Add audio track")
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                    onClicked: if (mainWindow) mainWindow.addAudioTrack("A" + (mainWindow.trackCount + 1))
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.trackAudio : theme.colors.elevated
                        border.color: theme.colors.borderColor; radius: 3
                    }
                    contentItem: Text {
                        text: parent.text; font: parent.font
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item { width: 8 }
                ZoomControl {
                    id: zoomCtl
                    onZoomRequested: (v) => root.zoomLevel = v
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 36
            visible: editorChrome !== null
            color: theme.colors.timelineHeader
            border.color: theme.colors.borderSubtle
            border.width: 0
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderMid
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 2

                Repeater {
                    model: [
                        { k: "select",  i: 0, tip: qsTr("Selection (V)") },
                        { k: "pen",     i: 1, tip: qsTr("Pen / mask (G)") },
                        { k: "razor",   i: 2, tip: qsTr("Razor (C)") },
                        { k: "ripple",  i: 3, tip: qsTr("Ripple edit (B)") },
                        { k: "rolling", i: 4, tip: qsTr("Rolling edit (N)") },
                        { k: "slip",    i: 5, tip: qsTr("Slip (Y)") },
                        { k: "slide",   i: 6, tip: qsTr("Slide (U)") },
                        { k: "hand",    i: 7, tip: qsTr("Hand (H)") },
                        { k: "zoom",    i: 8, tip: qsTr("Zoom (Z)") }
                    ]
                    delegate: ToolButton {
                        id: tb
                        required property var modelData
                        property int ti: modelData.i
                        implicitWidth: 30
                        implicitHeight: 26
                        enabled: editorChrome !== null
                        checkable: true
                        checked: editorChrome && editorChrome.activeTool === ti
                        hoverEnabled: true
                        ToolTip.text: modelData.tip
                        ToolTip.visible: hovered
                        ToolTip.delay: 350
                        onClicked: if (editorChrome)
                            editorChrome.activeTool = ti
                        background: Rectangle {
                            color: tb.checked ? theme.colors.accentMuted
                                 : tb.hovered ? theme.colors.surfaceHigh : "transparent"
                            border.color: tb.checked ? theme.colors.accent : "transparent"
                            border.width: tb.checked ? 1 : 0
                            radius: 3
                        }
                        contentItem: ToolIcon {
                            anchors.centerIn: parent
                            kind: modelData.k
                            pixelSize: 15
                            strokeCol: tb.checked ? theme.colors.accent
                                     : tb.hovered ? theme.colors.textPrimary
                                     : theme.colors.textSecondary
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 20
                    color: theme.colors.borderColor
                    opacity: 0.45
                }

                ToolButton {
                    id: snapBtn
                    implicitWidth: 34
                    implicitHeight: 30
                    enabled: editorChrome !== null
                    checkable: true
                    checked: editorChrome && editorChrome.snapEnabled
                    onClicked: if (editorChrome)
                        editorChrome.snapEnabled = !editorChrome.snapEnabled
                    ToolTip.text: qsTr("Snap (S)")
                    ToolTip.visible: hovered
                    background: Rectangle {
                        color: snapBtn.checked ? theme.colors.accentMuted
                             : snapBtn.hovered ? theme.colors.elevated : "transparent"
                        border.color: snapBtn.checked ? theme.colors.accent : "transparent"
                        radius: 4
                    }
                    contentItem: ToolIcon {
                        anchors.centerIn: parent
                        kind: "snap"
                        pixelSize: 15
                        strokeCol: snapBtn.checked ? theme.colors.accent
                                 : snapBtn.hovered ? theme.colors.textPrimary
                                 : theme.colors.textSecondary
                    }
                }
                ToolButton {
                    id: splitBtn
                    implicitWidth: 34
                    implicitHeight: 30
                    ToolTip.text: qsTr("Split at playhead (Ctrl+K)")
                    ToolTip.visible: hovered
                    onClicked: if (mainWindow)
                        mainWindow.splitAtPlayhead()
                    background: Rectangle {
                        color: splitBtn.hovered ? theme.colors.elevated : "transparent"
                        radius: 4
                    }
                    contentItem: Text {
                        text: theme.icons.toolSplit
                        font.pixelSize: 15
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ToolButton {
                    id: linkBtn
                    implicitWidth: 34
                    implicitHeight: 30
                    enabled: false
                    ToolTip.text: qsTr("Link / unlink clips")
                    ToolTip.visible: hovered
                    background: Rectangle {
                        color: linkBtn.hovered ? theme.colors.elevated : "transparent"
                        radius: 4
                    }
                    contentItem: Text {
                        text: theme.icons.toolLink
                        font.pixelSize: 15
                        color: theme.colors.textDisabled
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ToolButton {
                    id: markBtn
                    implicitWidth: 34
                    implicitHeight: 30
                    ToolTip.text: qsTr("Add marker (M)")
                    ToolTip.visible: hovered
                    onClicked: if (mainWindow)
                        mainWindow.addMarkerAtPlayhead()
                    background: Rectangle {
                        color: markBtn.hovered ? theme.colors.elevated : "transparent"
                        radius: 4
                    }
                    contentItem: Text {
                        text: theme.icons.toolMarker
                        font.pixelSize: 14
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                ToolButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    text: "\u21B6"
                    enabled: mainWindow && mainWindow.canUndo
                    ToolTip.text: qsTr("Undo (Ctrl+Z)")
                    ToolTip.visible: hovered
                    onClicked: if (mainWindow)
                        mainWindow.undo()
                    background: Rectangle {
                        color: parent.hovered && parent.enabled ? theme.colors.elevated : "transparent"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? theme.colors.textSecondary : theme.colors.textDisabled
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ToolButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    text: "\u21B7"
                    enabled: mainWindow && mainWindow.canRedo
                    ToolTip.text: qsTr("Redo")
                    ToolTip.visible: hovered
                    onClicked: if (mainWindow)
                        mainWindow.redo()
                    background: Rectangle {
                        color: parent.hovered && parent.enabled ? theme.colors.elevated : "transparent"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? theme.colors.textSecondary : theme.colors.textDisabled
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderColor
            }
        }

        Row {
            Layout.fillWidth: true
            height: 24

            Rectangle {
                width: root.headerWidth; height: parent.height
                color: theme.colors.timelineHeader
                Rectangle {
                    anchors.right: parent.right
                    width: 1; height: parent.height
                    color: theme.colors.borderColor
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1
                    color: theme.colors.borderColor
                }
                Label {
                    anchors.centerIn: parent
                    text: qsTr("TRACKS")
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: theme.typography.letterSpacingCaps
                    font.weight: Font.Bold
                }
            }

            TimelineRuler {
                width: parent.width - root.headerWidth
                height: parent.height
                zoomLevel:    root.zoomLevel
                pixelsPerSec: root.pixelsPerSec
                viewOffset:   root.viewOffset
                duration:     mainWindow ? mainWindow.compositionDuration : 30.0
            }
        }

        Row {
            Layout.fillWidth: true
            height: 22

            Rectangle {
                width: root.headerWidth
                height: parent.height
                color: theme.colors.timelineHeader
                Rectangle {
                    anchors.right: parent.right
                    width: 1
                    height: parent.height
                    color: theme.colors.borderColor
                }
                // OVERVIEW label removed per UI polish
            }

            Item {
                id: miniMapArea
                width: parent.width - root.headerWidth
                height: parent.height
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: theme.colors.timelineMinimapBg
                }

                Repeater {
                    model: miniModel

                    delegate: Rectangle {
                        x: miniMapArea.width * model.segX
                        width: Math.max(4, miniMapArea.width * model.segW)
                        height: miniMapArea.height - 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: model.segColor
                        radius: 0
                        opacity: 0.88
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: theme.colors.borderSubtle
                }
            }
        }

        Item {
            id: timelineBody
            Layout.fillWidth: true
            Layout.fillHeight: true
            onWidthChanged: root.rebuildSnapLines()
            onHeightChanged: root.rebuildSnapLines()

            Flickable {
                id: trackFlick
                anchors.fill: parent
                contentHeight: trackCol.height
                contentWidth: width
                clip: true
                flickableDirection: Flickable.VerticalFlick

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    background: Rectangle { color: theme.colors.borderSubtle; radius: 0 }
                    contentItem: Rectangle { color: theme.colors.scrollbar; radius: 0 }
                }

                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (!(event.modifiers & Qt.ShiftModifier))
                            return
                        const mo = root.maxTimelineOffset()
                        if (mo <= 0)
                            return
                        event.accepted = true
                        let delta = event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y
                        const step = (delta / 120) * Math.max(40, root.pixelsPerSec * root.zoomLevel * 0.35)
                        root.viewOffset = Math.max(0, Math.min(mo, root.viewOffset + step))
                    }
                }

                Column {
                    id: trackCol
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: trackModel

                        TimelineTrackView {
                            width: trackCol.width
                            trackId: model.trackId
                            trackName: model.trackName
                            trackType: model.trackType
                            trackIndex: model.trackIndex
                            trackRowHeight: model.heightPx
                            labelColorHex: model.labelColor
                            clipsJson: model.clipsJson
                            pixelsPerSec: root.pixelsPerSec
                            zoomLevel:    root.zoomLevel
                            viewOffset:   root.viewOffset
                        }
                    }
                }
            }

            Repeater {
                model: snapLinesModel
                delegate: Rectangle {
                    readonly property real snapT: model.tSec
                    x: root.headerWidth + (snapT - root.viewOffset) * root.pixelsPerSec * root.zoomLevel
                    y: 0
                    width: 1
                    height: timelineBody.height
                    color: theme.colors.snapLine
                    opacity: 0.55
                }
            }

            Item {
                id: playheadLine
                x: root.headerWidth + (appState ? (appState.playheadSeconds - root.viewOffset) * root.pixelsPerSec * root.zoomLevel : 0)
                y: 0
                width: 14
                height: parent.height
                z: 100
                visible: x >= root.headerWidth - 7 && x <= parent.width

                // Flag head
                Rectangle {
                    x: 0; y: 0
                    width: 14; height: 12
                    color: "#c86050"
                    radius: 1
                }
                Canvas {
                    x: 0; y: 12
                    width: 14; height: 5
                    onPaint: {
                        var c = getContext("2d")
                        c.reset()
                        c.fillStyle = "#c86050"
                        c.beginPath()
                        c.moveTo(0, 0)
                        c.lineTo(14, 0)
                        c.lineTo(7, 5)
                        c.closePath()
                        c.fill()
                    }
                }
                // Full-height line
                Rectangle {
                    x: 6
                    y: 17
                    width: 2
                    height: parent.height - 17
                    color: "#c86050"
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.leftMargin: -4
                    anchors.rightMargin: -4
                    cursorShape: Qt.SplitHCursor
                    drag.target: playheadLine
                    drag.axis: Drag.XAxis
                    drag.minimumX: root.headerWidth - 7
                    drag.maximumX: parent.width
                    onPositionChanged: (mouse) => {
                        if (drag.active && appState) {
                            const t = (playheadLine.x + 7 - root.headerWidth) / (root.pixelsPerSec * root.zoomLevel) + root.viewOffset
                            appState.playheadSeconds = Math.max(0, t)
                        }
                    }
                }
            }

            ScrollBar {
                id: hScroll
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: root.headerWidth
                anchors.right: parent.right
                orientation: Qt.Horizontal
                policy: ScrollBar.AlwaysOn
                size: {
                    const dur = mainWindow ? mainWindow.compositionDuration : 30
                    const pps = root.pixelsPerSec * root.zoomLevel
                    const totalW = dur * pps
                    const viewW = timelineBody.width - root.headerWidth
                    if (totalW <= 0 || viewW <= 0)
                        return 1
                    return Math.min(1, Math.max(0.04, viewW / totalW))
                }
                background: Rectangle { color: theme.colors.borderSubtle; radius: 0 }
                contentItem: Rectangle { color: theme.colors.scrollbar; radius: 0 }
                onPositionChanged: {
                    if (root._hScrollProgram)
                        return
                    const mo = root.maxTimelineOffset()
                    root._hScrollProgram = true
                    root.viewOffset = hScroll.position * mo
                    root._hScrollProgram = false
                }
            }
        }
    }
}
