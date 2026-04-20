import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import Fognitix

Item {
    id: root
    anchors.fill: parent

    Theme { id: theme }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.appBg
    }

    // ── Layout geometry ──────────────────────────────────────────────────────
    property int  leftDockInnerW:  300
    property int  midInspectorW:   240
    property int  rightDockW:      380
    property bool showLeftBody:    true
    property bool showMidInspector: false
    property bool showRightColumn: true
    property bool rightExpanded:   true
    property real previewRatio:    0.60

    // ── Tool / snap state (consumed by TimelinePanel) ─────────────────────
    property int  activeTool:  0
    property bool snapEnabled: false
    readonly property var toolNames: [
        qsTr("Selection"), qsTr("Pen"), qsTr("Razor"), qsTr("Ripple Edit"),
        qsTr("Rolling Edit"), qsTr("Slip"), qsTr("Slide"), qsTr("Hand"), qsTr("Zoom")
    ]

    // ── External callbacks ────────────────────────────────────────────────
    property var openImportFn: null
    property var openExportFn: null

    PanelRegistry { id: panelCatalog }
    readonly property var panelRegistry: panelCatalog.panels

    // ── Active panels in left dock ────────────────────────────────────────
    ListModel { id: leftActivePanels }
    ListModel { id: floatingPanels }
    property int leftCurrentId: 0

    readonly property var panelMenuItems: {
        const result = []
        let lastCat = ""
        for (const p of panelRegistry) {
            if (p.category !== lastCat) {
                result.push({ type: "header", text: p.category, id: -1, name: "" })
                lastCat = p.category
            }
            result.push({ type: "panel", id: p.id, name: p.name, category: p.category, text: "" })
        }
        return result
    }

    function addPanel(panelId) {
        for (let i = 0; i < leftActivePanels.count; i++) {
            if (leftActivePanels.get(i).panelId === panelId) {
                root.leftCurrentId = panelId
                addPanelPopup.close()
                return
            }
        }
        const p = panelRegistry.find(x => x.id === panelId)
        if (p) {
            leftActivePanels.append({ panelId: panelId, panelName: p.name })
            root.leftCurrentId = panelId
            addPanelPopup.close()
        }
    }

    function movePanelByIndex(fromIdx, toIdx) {
        if (fromIdx < 0 || fromIdx >= leftActivePanels.count)
            return
        const clampedTo = Math.max(0, Math.min(leftActivePanels.count - 1, toIdx))
        if (clampedTo === fromIdx)
            return
        leftActivePanels.move(fromIdx, clampedTo, 1)
    }

    function movePanel(panelId, delta) {
        for (let i = 0; i < leftActivePanels.count; i++) {
            if (leftActivePanels.get(i).panelId === panelId) {
                movePanelByIndex(i, i + delta)
                return
            }
        }
    }

    function panelById(panelId) {
        return panelRegistry.find(x => x.id === panelId)
    }

    function removePanel(panelId) {
        if (leftActivePanels.count <= 1) return
        for (let i = 0; i < leftActivePanels.count; i++) {
            if (leftActivePanels.get(i).panelId === panelId) {
                leftActivePanels.remove(i)
                if (root.leftCurrentId === panelId)
                    root.leftCurrentId = leftActivePanels.get(Math.min(i, leftActivePanels.count - 1)).panelId
                return
            }
        }
    }

    function floatPanel(panelId) {
        const panel = panelById(panelId)
        if (!panel)
            return
        removePanel(panelId)
        floatingPanels.append({
            panelId: panelId,
            panelName: panel.name,
            posX: 180 + (floatingPanels.count * 24),
            posY: 120 + (floatingPanels.count * 24),
            widthPx: 460,
            heightPx: 360
        })
    }

    function redockFloating(index) {
        if (index < 0 || index >= floatingPanels.count)
            return
        const row = floatingPanels.get(index)
        floatingPanels.remove(index)
        addPanel(row.panelId)
        showLeftBody = true
    }

    function isPanelActive(panelId) {
        for (let i = 0; i < leftActivePanels.count; i++)
            if (leftActivePanels.get(i).panelId === panelId) return true
        return false
    }

    function _syncPlaceholderMeta() {
        if (!leftDockPhLoader.item)
            return
        const p = panelRegistry.find(x => x.id === leftCurrentId)
        leftDockPhLoader.item.panelTitle = p ? p.name : ""
        leftDockPhLoader.item.panelCategory = p ? p.category : ""
    }

    // ── Public API ────────────────────────────────────────────────────────
    function focusAI() { showRightColumn = true; rightExpanded = true }
    function focusEffectsPanel() { openLeftDockPanel(6) }

    /** Show left dock and switch to a built-in panel (0–28). Window menu + dock rail use this. */
    function openLeftDockPanel(panelId) {
        showLeftBody = true
        addPanel(panelId)
    }

    function openMidInspector() {
        showMidInspector = true
    }

    function resetWindowLayout() {
        leftDockInnerW = 300
        midInspectorW = 240
        rightDockW = 380
        showLeftBody = true
        showMidInspector = false
        showRightColumn = true
        rightExpanded = true
        previewRatio = 0.60
        leftActivePanels.clear()
        leftActivePanels.append({ panelId: 0,  panelName: "Project" })
        leftActivePanels.append({ panelId: 1,  panelName: "Media" })
        leftCurrentId = 1
        floatingPanels.clear()
    }

    function emphasizePreview() {
        previewRatio = Math.min(0.82, Math.max(0.48, previewRatio + 0.1))
    }

    function emphasizeTimeline() {
        previewRatio = Math.max(0.42, previewRatio - 0.1)
    }

    function syncToolName() {
        if (mainWindow) {
            const n = toolNames[Math.max(0, Math.min(activeTool, toolNames.length - 1))]
            mainWindow.setUiToolName(n)
        }
    }

    onActiveToolChanged: syncToolName()

    Component.onCompleted: {
        if (mainWindow) {
            const L = mainWindow.loadEditorLayout()
            if (L.leftInner !== undefined)  leftDockInnerW   = Math.max(200, Math.min(420, L.leftInner))
            if (L.midW     !== undefined)   midInspectorW    = Math.max(180, Math.min(360, L.midW))
            if (L.rightW   !== undefined)   rightDockW       = Math.max(320, Math.min(680, L.rightW))
            if (L.showLeftBody !== undefined) showLeftBody   = L.showLeftBody
            if (L.showMid  !== undefined)   showMidInspector = L.showMid
            if (L.showRight !== undefined)  showRightColumn  = L.showRight
            if (L.previewRatio !== undefined) {
                const r = Number(L.previewRatio)
                if (!isNaN(r)) previewRatio = Math.min(0.85, Math.max(0.45, r))
            }
            if (L.leftPanelIds !== undefined) {
                const ids = String(L.leftPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                leftActivePanels.clear()
                for (const pid of ids) {
                    const p = panelById(pid)
                    if (p)
                        leftActivePanels.append({ panelId: p.id, panelName: p.name })
                }
                if (leftActivePanels.count === 0) {
                    leftActivePanels.append({ panelId: 0, panelName: "Project" })
                    leftActivePanels.append({ panelId: 1, panelName: "Media" })
                }
            }
            if (L.leftCurrentId !== undefined)
                leftCurrentId = Number(L.leftCurrentId)
            if (L.floatingPanelsJson !== undefined && String(L.floatingPanelsJson).length > 0) {
                let rows = []
                try { rows = JSON.parse(String(L.floatingPanelsJson)) } catch (e) { rows = [] }
                for (const row of rows) {
                    const p = panelById(Number(row.panelId))
                    if (!p)
                        continue
                    floatingPanels.append({
                        panelId: p.id,
                        panelName: p.name,
                        posX: Number(row.posX) || 220,
                        posY: Number(row.posY) || 160,
                        widthPx: Number(row.widthPx) || 460,
                        heightPx: Number(row.heightPx) || 360
                    })
                }
            } else if (L.floatingPanelIds !== undefined) {
                const fids = String(L.floatingPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                for (const pid of fids) {
                    const p = panelById(pid)
                    if (p)
                        floatingPanels.append({ panelId: p.id, panelName: p.name, posX: 220, posY: 160, widthPx: 460, heightPx: 360 })
                }
            }
        }
        if (leftActivePanels.count === 0) {
            leftActivePanels.append({ panelId: 0,  panelName: "Project" })
            leftActivePanels.append({ panelId: 1,  panelName: "Media" })
            leftActivePanels.append({ panelId: 6,  panelName: "Effects" })
            leftActivePanels.append({ panelId: 22, panelName: "Audio" })
        }
        if (!isPanelActive(leftCurrentId))
            leftCurrentId = leftActivePanels.get(0).panelId
        syncToolName()
    }

    Component.onDestruction: {
        saveLayoutTimer.stop()
        if (mainWindow) mainWindow.saveEditorLayout(collectLayoutMap(true))
    }

    function scheduleSaveLayout() { saveLayoutTimer.restart() }

    Timer {
        id: saveLayoutTimer
        interval: 350; repeat: false
        onTriggered: if (mainWindow) mainWindow.saveEditorLayout(root.collectLayoutMap(false))
    }

    function collectLayoutMap(skipLiveGeometry) {
        let pr = previewRatio
        if (!skipLiveGeometry && centerSplit.height > 80 && pvSlot.height > 40)
            pr = Math.min(0.85, Math.max(0.45, pvSlot.height / centerSplit.height))
        const panelIds = []
        for (let i = 0; i < leftActivePanels.count; i++)
            panelIds.push(leftActivePanels.get(i).panelId)
        const floatingIds = []
        for (let i = 0; i < floatingPanels.count; i++)
            floatingIds.push(floatingPanels.get(i).panelId)
        const floatingRows = []
        for (let i = 0; i < floatingPanels.count; i++) {
            const r = floatingPanels.get(i)
            floatingRows.push({
                panelId: r.panelId,
                panelName: r.panelName,
                posX: r.posX,
                posY: r.posY,
                widthPx: r.widthPx,
                heightPx: r.heightPx
            })
        }
        return { leftInner: leftDockInnerW, midW: midInspectorW, rightW: rightDockW,
                 showLeftBody: showLeftBody, showMid: showMidInspector,
                 showRight: showRightColumn, previewRatio: pr,
                 leftPanelIds: panelIds.join(","),
                 leftCurrentId: leftCurrentId,
                 floatingPanelIds: floatingIds.join(","),
                 floatingPanelsJson: JSON.stringify(floatingRows) }
    }

    onLeftDockInnerWChanged:  scheduleSaveLayout()
    onMidInspectorWChanged:   scheduleSaveLayout()
    onRightDockWChanged:      scheduleSaveLayout()
    onShowLeftBodyChanged:    scheduleSaveLayout()
    onShowMidInspectorChanged: scheduleSaveLayout()
    onShowRightColumnChanged: scheduleSaveLayout()
    onRightExpandedChanged:   scheduleSaveLayout()
    onPreviewRatioChanged:    scheduleSaveLayout()

    Connections {
        target: mainWindow
        function onWorkspaceChanged() {
            const layout = mainWindow.workspaceLayout(mainWindow.workspace)
            if (layout.leftTab !== undefined) {
                const ids = [0, 1, 6, 22]
                root.leftCurrentId = ids[Math.min(3, Math.max(0, layout.leftTab))]
            }
        }
    }

    // ── "Add Panel" popup ─────────────────────────────────────────────────
    Popup {
        id: addPanelPopup
        width: 280
        height: Math.min(560, panelMenuListView.contentHeight + 2)
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: theme.colors.panelAlt
            border.color: theme.colors.borderSoft
            border.width: 1
            radius: 0
        }

        contentItem: ListView {
            id: panelMenuListView
            clip: true
            model: root.panelMenuItems
            spacing: 0
            delegate: Loader {
                required property var modelData
                required property int index
                width: panelMenuListView.width
                height: modelData.type === "header" ? 24 : 28
                sourceComponent: modelData.type === "header" ? catHeaderComp : panelItemComp
            }
        }
    }

    component CatHeader: Rectangle {
        required property var modelData
        height: 24
        color: theme.colors.surfaceRaised
        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: modelData.text.toUpperCase()
            color: theme.colors.textDisabled
            font.pixelSize: 9
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }
    }

    component PanelMenuItem: Rectangle {
        id: pmItem
        required property var modelData
        height: 28
        color: pmHover.containsMouse ? theme.colors.surfacePeak : "transparent"
        HoverHandler { id: pmHover }
        Row {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 8
            spacing: 6
            anchors.verticalCenter: undefined
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: root.isPanelActive(pmItem.modelData.id) ? "\u2713" : " "
                color: theme.colors.accent
                font.pixelSize: 11
                width: 14
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: pmItem.modelData.name
                color: root.isPanelActive(pmItem.modelData.id) ? theme.colors.textPrimary : theme.colors.textSecondary
                font.pixelSize: 12
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.addPanel(pmItem.modelData.id)
        }
    }

    Component { id: catHeaderComp;  CatHeader   {} }
    Component { id: panelItemComp;  PanelMenuItem {} }

    Component { id: compProject; ProjectPanel {} }
    Component { id: compMediaPool; MediaPoolPanel {} }
    Component { id: compMediaBrowser; MediaBrowserPanel {} }
    Component { id: compLibrary; LibraryPanel {} }
    Component { id: compFootageInfo; FootageInfoPanel {} }
    Component { id: compMetadata; MetadataPanel {} }
    Component { id: compEffectsBrowser; EffectsBrowser {} }
    Component { id: compEffectsPanel; EffectsPanel {} }
    Component { id: compTransitions; TransitionsPanel {} }
    Component { id: compEssentialGfx; EssentialGraphicsPanel {} }
    Component { id: compContentAware; ContentAwareFillPanel {} }
    Component { id: compColor; ColorPanel {} }
    Component { id: compLumetriScopes; LumetriScopesPanel {} }
    Component { id: compCharacter; CharacterPanel {} }
    Component { id: compParagraph; ParagraphPanel {} }
    Component { id: compMotionSketch; MotionSketchPanel {} }
    Component { id: compGraphEditor; GraphEditorPanel {} }
    Component { id: compMaskInterp; MaskInterpolationPanel {} }
    Component { id: compSmoother; SmootherPanel {} }
    Component { id: compTracker; TrackerPanel {} }
    Component { id: compThreeD; ThreeDPanel {} }
    Component { id: compFlowchart; FlowchartPanel {} }
    Component { id: compAudioMixer; AudioMixerPanel {} }
    Component { id: compAlign; AlignPanel {} }
    Component { id: compMarkers; MarkersPanel {} }
    Component { id: compHistory; HistoryPanel {} }
    Component { id: compRenderQueue; RenderQueuePanel {} }
    Component { id: compInspector; InspectorPanel {} }
    Component { id: compInfo; InfoPanel {} }
    Component { id: compPlaceholder; PanelPlaceholder {} }

    function panelSourceComponent(panelId) {
        switch (panelId) {
        case 0: return compProject
        case 1: return compMediaPool
        case 2: return compMediaBrowser
        case 3: return compLibrary
        case 4: return compFootageInfo
        case 5: return compMetadata
        case 6: return compEffectsBrowser
        case 7: return compEffectsPanel
        case 8: return compTransitions
        case 9: return compEssentialGfx
        case 10: return compContentAware
        case 11: return compColor
        case 12: return compLumetriScopes
        case 13: return compCharacter
        case 14: return compParagraph
        case 15: return compMotionSketch
        case 16: return compGraphEditor
        case 17: return compMaskInterp
        case 18: return compSmoother
        case 19: return compTracker
        case 20: return compThreeD
        case 21: return compFlowchart
        case 22: return compAudioMixer
        case 23: return compAlign
        case 24: return compMarkers
        case 25: return compHistory
        case 26: return compRenderQueue
        case 27: return compInspector
        case 28: return compInfo
        default: return compPlaceholder
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top chrome bar (Resolve / Premiere–class density) ───────────────
        Rectangle {
            Layout.fillWidth: true
            height: 42
            color: theme.colors.menuBarBackground

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: theme.colors.borderSoft
                opacity: 0.85
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                // Import / Edit / Export pill
                Row {
                    spacing: 0
                    height: 30
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: segImport.implicitWidth + segEdit.implicitWidth + segExport.implicitWidth + 4
                        height: 30
                        radius: 4
                        color: theme.colors.timelineBg
                        border.color: theme.colors.borderSubtle
                        border.width: 1
                        Row {
                            anchors.centerIn: parent
                            spacing: 0
                            ToolButton {
                                id: segImport
                                flat: true
                                implicitWidth: 68
                                implicitHeight: 28
                                text: qsTr("Import")
                                font.pixelSize: theme.typography.caption
                                font.weight: Font.Medium
                                onClicked: if (root.openImportFn) root.openImportFn()
                                ToolTip.text: qsTr("Import media"); ToolTip.visible: hovered
                                background: Rectangle {
                                    radius: 3
                                    color: segImport.hovered ? theme.colors.surfaceHigh : "transparent"
                                }
                                contentItem: Text {
                                    text: segImport.text
                                    font: segImport.font
                                    color: theme.colors.textMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Rectangle {
                                width: 1
                                height: 16
                                color: theme.colors.borderSubtle
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                id: segEdit
                                implicitWidth: 58
                                implicitHeight: 28
                                radius: 3
                                color: theme.colors.accentMuted
                                border.width: 1
                                border.color: theme.colors.borderFocusRing
                                Label {
                                    anchors.centerIn: parent
                                    text: qsTr("Edit")
                                    font.pixelSize: theme.typography.caption
                                    font.weight: Font.Bold
                                    color: theme.colors.accent
                                }
                            }
                            Rectangle {
                                width: 1
                                height: 16
                                color: theme.colors.borderSubtle
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            ToolButton {
                                id: segExport
                                flat: true
                                implicitWidth: 70
                                implicitHeight: 28
                                text: qsTr("Export")
                                font.pixelSize: theme.typography.caption
                                font.weight: Font.Medium
                                onClicked: if (root.openExportFn) root.openExportFn()
                                ToolTip.text: qsTr("Export / render"); ToolTip.visible: hovered
                                background: Rectangle {
                                    radius: 3
                                    color: segExport.hovered ? theme.colors.surfaceHigh : "transparent"
                                }
                                contentItem: Text {
                                    text: segExport.text
                                    font: segExport.font
                                    color: theme.colors.textMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 18
                    color: theme.colors.borderSubtle
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: mainWindow ? mainWindow.projectName : qsTr("Untitled Project")
                    color: theme.colors.textPrimary
                    font.pixelSize: theme.typography.caption
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                }

                Rectangle { width: 1; height: 14; color: theme.colors.borderSubtle; Layout.alignment: Qt.AlignVCenter }

                Label {
                    text: qsTr("%1 tracks · %2 clips").arg(mainWindow ? mainWindow.trackCount : 0).arg(mainWindow ? mainWindow.clipCount : 0)
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Panel toggle buttons
                Repeater {
                    model: [
                        { label: qsTr("Panels"),    prop: "showLeftBody" },
                        { label: qsTr("Inspector"), prop: "showMidInspector" },
                        { label: qsTr("AI Chat"),    prop: "showRightColumn" }
                    ]
                    delegate: ToolButton {
                        required property var modelData
                        required property int index
                        Layout.alignment: Qt.AlignVCenter
                        checkable: true
                        checked: index === 0 ? root.showLeftBody : (index === 1 ? root.showMidInspector : root.showRightColumn)
                        implicitHeight: 28
                        implicitWidth: labelItem.implicitWidth + 22
                        ToolTip.text: qsTr("Toggle") + " " + modelData.label; ToolTip.visible: hovered
                        onClicked: {
                            if (index === 0) root.showLeftBody = !root.showLeftBody
                            else if (index === 1) root.showMidInspector = !root.showMidInspector
                            else root.showRightColumn = !root.showRightColumn
                        }
                        background: Rectangle {
                            radius: 4
                            color: parent.checked ? theme.colors.accentMuted : (parent.hovered ? theme.colors.surfaceHigh : "transparent")
                            border.width: parent.checked ? 1 : 0
                            border.color: parent.checked ? theme.colors.borderFocusRing : theme.colors.borderSoft
                        }
                        contentItem: Text {
                            id: labelItem
                            text: modelData.label
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: parent.checked ? theme.colors.accent : theme.colors.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    height: 30
                    width: aiAgentRow.implicitWidth + 20
                    radius: 4
                    color: aiAgentHover.hovered ? theme.colors.accentMuted : theme.colors.surfaceRaised
                    border.width: 1
                    border.color: aiAgentHover.hovered ? theme.colors.borderFocusRing : theme.colors.borderSoft

                    HoverHandler { id: aiAgentHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.focusAI()
                    }

                    Row {
                        id: aiAgentRow
                        anchors.centerIn: parent
                        spacing: 7
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            anchors.verticalCenter: parent.verticalCenter
                            color: mainWindow && mainWindow.aiBusy ? theme.colors.warning : theme.colors.success
                        }
                        Text {
                            text: qsTr("AI Agent")
                            font.pixelSize: theme.typography.caption
                            font.weight: Font.Medium
                            color: theme.colors.accentText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Workspace + preview — Fusion ComboBox (bounded popup); avoids broken Menu.popup layout
                Rectangle {
                    width: 1
                    height: 14
                    color: theme.colors.borderSubtle
                    Layout.alignment: Qt.AlignVCenter
                }

                Row {
                    spacing: 6
                    Layout.alignment: Qt.AlignVCenter
                    Layout.maximumWidth: 260
                    ComboBox {
                        id: wsCombo
                        implicitHeight: 28
                        implicitWidth: 124
                        Layout.maximumWidth: 140
                        padding: 6
                        leftPadding: 8
                        rightPadding: 28
                        model: [qsTr("Standard"), qsTr("Editing"), qsTr("Color"), qsTr("Motion Tracking"), qsTr("VFX")]
                        font.pixelSize: 10
                        hoverEnabled: true
                        ToolTip.text: qsTr("Workspace layout"); ToolTip.visible: hovered
                        delegate: ItemDelegate {
                            required property int index
                            width: wsCombo.width
                            implicitHeight: 26
                            text: wsCombo.textAt(index)
                            font.pixelSize: 11
                            background: Rectangle {
                                implicitWidth: parent.width
                                implicitHeight: 26
                                color: parent.highlighted ? theme.colors.surfacePeak : theme.colors.chromePopup
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: theme.colors.textPrimary
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }
                        background: Rectangle {
                            radius: 4
                            color: wsCombo.down || wsCombo.popup.opened ? theme.colors.chromePopupHover
                                 : wsCombo.hovered ? theme.colors.surfacePeak : theme.colors.chromePopup
                            border.color: wsCombo.activeFocus || wsCombo.popup.opened ? theme.colors.accent : theme.colors.chromePopupBorder
                            border.width: 1
                        }
                        contentItem: Text {
                            text: wsCombo.displayText
                            font: wsCombo.font
                            color: theme.colors.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            leftPadding: 0
                        }
                        function syncWsIndex() {
                            if (!mainWindow)
                                return
                            for (let i = 0; i < wsCombo.count; ++i) {
                                if (wsCombo.textAt(i) === mainWindow.workspace) {
                                    wsCombo.currentIndex = i
                                    return
                                }
                            }
                            wsCombo.currentIndex = 0
                        }
                        Component.onCompleted: syncWsIndex()
                        Connections {
                            target: mainWindow
                            function onWorkspaceChanged() { wsCombo.syncWsIndex() }
                        }
                        onActivated: (i) => {
                            if (mainWindow && i >= 0 && i < wsCombo.count)
                                mainWindow.workspace = wsCombo.textAt(i)
                        }
                    }
                    ComboBox {
                        id: pqCombo
                        implicitHeight: 28
                        implicitWidth: 84
                        Layout.maximumWidth: 96
                        padding: 6
                        leftPadding: 8
                        rightPadding: 28
                        model: [qsTr("Full"), qsTr("Half"), qsTr("Quarter")]
                        font.pixelSize: 10
                        hoverEnabled: true
                        ToolTip.text: qsTr("Playback / preview resolution"); ToolTip.visible: hovered
                        delegate: ItemDelegate {
                            required property int index
                            width: pqCombo.width
                            implicitHeight: 26
                            text: pqCombo.textAt(index)
                            font.pixelSize: 11
                            background: Rectangle {
                                implicitWidth: parent.width
                                implicitHeight: 26
                                color: parent.highlighted ? theme.colors.surfacePeak : theme.colors.chromePopup
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: theme.colors.textSecondary
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }
                        background: Rectangle {
                            radius: 4
                            color: pqCombo.down || pqCombo.popup.opened ? theme.colors.chromePopupHover
                                 : pqCombo.hovered ? theme.colors.surfacePeak : theme.colors.chromePopup
                            border.color: pqCombo.activeFocus || pqCombo.popup.opened ? theme.colors.accent : theme.colors.chromePopupBorder
                            border.width: 1
                        }
                        contentItem: Text {
                            text: pqCombo.displayText
                            font: pqCombo.font
                            color: theme.colors.textSecondary
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        function syncPqIndex() {
                            if (!mainWindow)
                                return
                            for (let i = 0; i < pqCombo.count; ++i) {
                                if (pqCombo.textAt(i) === mainWindow.previewQuality) {
                                    pqCombo.currentIndex = i
                                    return
                                }
                            }
                            pqCombo.currentIndex = 0
                        }
                        Component.onCompleted: syncPqIndex()
                        Connections {
                            target: mainWindow
                            function onPreviewQualityChanged() { pqCombo.syncPqIndex() }
                        }
                        onActivated: (i) => {
                            if (mainWindow && i >= 0 && i < pqCombo.count)
                                mainWindow.previewQuality = pqCombo.textAt(i)
                        }
                    }
                }

                // ── Settings button ──────────────────────────────────────────
                ToolButton {
                    id: settingsBtn
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 28
                    implicitWidth: 76
                    ToolTip.text: qsTr("Settings"); ToolTip.visible: hovered
                    onClicked: {
                        let p = root
                        while (p) {
                            if (typeof p.openSettingsWindow === "function") {
                                p.openSettingsWindow()
                                break
                            }
                            p = p.parent
                        }
                    }
                    background: Rectangle {
                        radius: 4
                        color: settingsBtn.hovered ? theme.colors.surfaceHigh : theme.colors.elevated
                        border.width: 1
                        border.color: theme.colors.borderSoft
                    }
                    contentItem: Text {
                        text: qsTr("Settings")
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: theme.colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                ToolButton {
                    id: userBtn
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 30
                    implicitWidth: 30
                    ToolTip.text: qsTr("User profile"); ToolTip.visible: hovered
                    flat: true
                    background: Rectangle {
                        radius: 15
                        color: userBtn.hovered ? theme.colors.accentMuted : theme.colors.surfaceRaised
                        border.width: 1
                        border.color: userBtn.hovered ? theme.colors.borderFocusRing : theme.colors.borderSoft
                    }
                    contentItem: Text {
                        text: qsTr("U")
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: theme.colors.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle }
        }

        // ── Main split view ───────────────────────────────────────────────
        SplitView {
            id: mainHSplit
            orientation: Qt.Horizontal
            Layout.fillWidth: true; Layout.fillHeight: true

            handle: Item {
                implicitWidth: 3
                Rectangle {
                    anchors.centerIn: parent
                    width: 1
                    height: parent.height
                    color: SplitHandle.pressed ? theme.colors.splitterActive
                         : SplitHandle.hovered ? theme.colors.chromeEdge : theme.colors.splitter
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }

            // ── Left dock ─────────────────────────────────────────────────
            Item {
                id: leftPane
                SplitView.minimumWidth:  root.showLeftBody ? 220 : 0
                SplitView.preferredWidth: root.showLeftBody ? root.leftDockInnerW : 0
                SplitView.maximumWidth:  root.showLeftBody ? 560 : 0
                onWidthChanged: {
                    if (root.showLeftBody && width > 20)
                        root.leftDockInnerW = Math.min(560, Math.max(220, width))
                }

                Rectangle {
                    anchors.fill: parent
                    visible: root.showLeftBody
                    color: theme.colors.panelBackground
                    border.color: theme.colors.borderHard; border.width: 1

                    ColumnLayout {
                        anchors.fill: parent; spacing: 0

                        // Tab bar
                        Rectangle {
                            Layout.fillWidth: true; height: 34
                            color: theme.colors.surfaceRaised

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 0; anchors.rightMargin: 0
                                spacing: 0

                                // Scrollable tab area
                                Item {
                                    Layout.fillWidth: true; height: 34; clip: true
                                    Flickable {
                                        anchors.fill: parent
                                        flickableDirection: Flickable.HorizontalFlick
                                        contentWidth: tabRow.implicitWidth
                                        clip: true; interactive: contentWidth > width
                                        Row {
                                            id: tabRow
                                            height: 34; spacing: 0
                                            Repeater {
                                                model: leftActivePanels
                                                delegate: Item {
                                                    id: tabItem
                                                    required property int index
                                                    required property int panelId
                                                    required property string panelName
                                                    property real _dragStartX: 0
                                                    width: Math.max(74, tabLabel.implicitWidth + 30)
                                                    height: 34
                                                    readonly property bool sel: root.leftCurrentId === panelId
                                                    HoverHandler { id: tabHover }
                                                    Rectangle {
                                                        anchors.fill: parent
                                                        color: tabItem.sel ? theme.colors.panelBackground : (tabHover.hovered ? theme.colors.surfacePeak : "transparent")
                                                    }
                                                    Label {
                                                        id: tabLabel
                                                        anchors.centerIn: parent
                                                        anchors.horizontalCenterOffset: tabItem.sel && tabHover.hovered ? -8 : 0
                                                        Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 120 } }
                                                        text: panelName
                                                        font.pixelSize: theme.typography.caption
                                                        font.weight: tabItem.sel ? Font.Medium : Font.Normal
                                                        color: tabItem.sel ? theme.colors.textPrimary : theme.colors.textSecondary
                                                    }
                                                    // Close button (appears on hover when not last tab)
                                                    ToolButton {
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.rightMargin: 2
                                                        width: 18; height: 18; flat: true
                                                        visible: tabHover.hovered && leftActivePanels.count > 1
                                                        text: "\u2715"
                                                        font.pixelSize: 9
                                                        onClicked: root.removePanel(panelId)
                                                        background: Rectangle {
                                                            color: parent.hovered ? Qt.rgba(1,1,1,0.15) : "transparent"; radius: 2
                                                        }
                                                        contentItem: Text {
                                                            text: parent.text; font: parent.font
                                                            color: theme.colors.textSecondary
                                                            horizontalAlignment: Text.AlignHCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                        }
                                                    }
                                                    // Active underline
                                                    Rectangle {
                                                        anchors.bottom: parent.bottom
                                                        width: parent.width; height: 2
                                                        color: theme.colors.accent
                                                        visible: tabItem.sel
                                                    }
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                        cursorShape: Qt.PointingHandCursor
                                                        onPressed: (event) => {
                                                            if (event.button === Qt.LeftButton)
                                                                tabItem._dragStartX = event.x
                                                        }
                                                        onPositionChanged: (event) => {
                                                            if (!(pressedButtons & Qt.LeftButton))
                                                                return
                                                            const dx = event.x - tabItem._dragStartX
                                                            if (dx > tabItem.width * 0.7 && tabItem.index < leftActivePanels.count - 1) {
                                                                root.movePanelByIndex(tabItem.index, tabItem.index + 1)
                                                                tabItem._dragStartX = event.x
                                                            } else if (dx < -tabItem.width * 0.7 && tabItem.index > 0) {
                                                                root.movePanelByIndex(tabItem.index, tabItem.index - 1)
                                                                tabItem._dragStartX = event.x
                                                            }
                                                        }
                                                        onClicked: (event) => {
                                                            if (event.button === Qt.LeftButton)
                                                                root.leftCurrentId = panelId
                                                            else if (event.button === Qt.RightButton)
                                                                tabMenu.open()
                                                        }
                                                    }
                                                    Menu {
                                                        id: tabMenu
                                                        MenuItem {
                                                            text: qsTr("Move Left")
                                                            enabled: tabItem.index > 0
                                                            onTriggered: root.movePanel(panelId, -1)
                                                        }
                                                        MenuItem {
                                                            text: qsTr("Move Right")
                                                            enabled: tabItem.index < leftActivePanels.count - 1
                                                            onTriggered: root.movePanel(panelId, +1)
                                                        }
                                                        MenuSeparator {}
                                                        MenuItem {
                                                            text: qsTr("Float Panel")
                                                            onTriggered: root.floatPanel(panelId)
                                                        }
                                                        MenuItem {
                                                            text: qsTr("Close Panel")
                                                            enabled: leftActivePanels.count > 1
                                                            onTriggered: root.removePanel(panelId)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // "+" button to add panels
                                ToolButton {
                                    id: addPanelBtn
                                    implicitWidth: 30; implicitHeight: 30; flat: true
                                    text: "+"
                                    font.pixelSize: 16; font.weight: Font.Light
                                    ToolTip.text: qsTr("Add panel"); ToolTip.visible: hovered
                                    onClicked: {
                                        addPanelPopup.x = addPanelBtn.x - addPanelPopup.width + addPanelBtn.width
                                        addPanelPopup.y = addPanelBtn.height
                                        addPanelPopup.parent = addPanelBtn
                                        addPanelPopup.open()
                                    }
                                    background: Rectangle { color: parent.hovered ? theme.colors.surfacePeak : "transparent" }
                                    contentItem: Text {
                                        text: parent.text; font: parent.font
                                        color: theme.colors.textSecondary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle }
                        }

                        // Quick dock rail — minimal by design (use + Add Panel for everything else)
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: theme.colors.panelAlt
                            border.color: theme.colors.borderMid
                            border.width: 0
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 5
                                anchors.rightMargin: 5
                                spacing: 3
                                Repeater {
                                    model: [
                                        { pid: 1,  short: qsTr("Media"),   tip: qsTr("Media Pool") },
                                        { pid: 6,  short: qsTr("Effects"), tip: qsTr("Effects Browser") },
                                        { pid: 22, short: qsTr("Audio"),   tip: qsTr("Audio Mixer") },
                                        { pid: 11, short: qsTr("Color"),   tip: qsTr("Color Panel") }
                                    ]
                                    delegate: ToolButton {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.maximumWidth: 72
                                        Layout.minimumWidth: 36
                                        Layout.preferredHeight: 24
                                        flat: true
                                        text: modelData.short
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                        ToolTip.text: modelData.tip
                                        ToolTip.visible: hovered
                                        ToolTip.delay: 400
                                        onClicked: root.openLeftDockPanel(modelData.pid)
                                        background: Rectangle {
                                            radius: 3
                                            color: parent.down ? theme.colors.surfacePeak
                                                 : parent.hovered ? theme.colors.chromePopupHover : theme.colors.chromePopup
                                            border.color: root.leftCurrentId === modelData.pid ? theme.colors.accent : theme.colors.chromePopupBorder
                                            border.width: root.leftCurrentId === modelData.pid ? 1 : 1
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            font: parent.font
                                            color: root.leftCurrentId === modelData.pid ? theme.colors.accent : theme.colors.textSecondary
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: theme.colors.borderSubtle
                            }
                        }

                        // Panel stack (wired 0–28 + catalog placeholders 29+)
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Loader {
                                id: leftDockBuiltinLoader
                                anchors.fill: parent
                                active: root.leftCurrentId >= 0 && root.leftCurrentId <= 28
                                visible: active
                                sourceComponent: root.panelSourceComponent(root.leftCurrentId)
                            }

                            Loader {
                                id: leftDockPhLoader
                                anchors.fill: parent
                                active: root.leftCurrentId > 28
                                visible: active
                                sourceComponent: compPlaceholder
                                onLoaded: root._syncPlaceholderMeta()
                            }

                            Connections {
                                target: root
                                function onLeftCurrentIdChanged() {
                                    if (root.leftCurrentId > 28)
                                        Qt.callLater(root._syncPlaceholderMeta)
                                }
                            }
                        }
                    }
                }
            }

            // ── Center: preview + timeline ────────────────────────────────
            SplitView {
                id: centerSplit
                orientation: Qt.Vertical
                SplitView.fillWidth: true
                SplitView.minimumWidth: 480

                handle: Item {
                    implicitHeight: 4
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 1
                        color: SplitHandle.pressed ? theme.colors.splitterActive
                             : SplitHandle.hovered ? theme.colors.chromeEdge : theme.colors.splitter
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }
                }

                Item {
                    id: pvSlot
                    SplitView.preferredHeight: Math.max(260, centerSplit.height * root.previewRatio)
                    SplitView.minimumHeight: 200
                    SplitView.maximumHeight: Math.max(340, centerSplit.height * 0.82)
                    PreviewPanel { anchors.fill: parent }
                }

                TimelinePanel {
                    editorChrome: root
                    SplitView.minimumHeight: 180
                    SplitView.fillHeight: true
                }

                Connections {
                    target: centerSplit
                    function onHeightChanged() { root.scheduleSaveLayout() }
                }
            }

            // ── Mid inspector ──────────────────────────────────────────────
            Item {
                id: midPane
                SplitView.minimumWidth:  root.showMidInspector ? 180 : 0
                SplitView.preferredWidth: root.showMidInspector ? root.midInspectorW : 0
                SplitView.maximumWidth:  root.showMidInspector ? 380 : 0
                onWidthChanged: {
                    if (root.showMidInspector && width > 10)
                        root.midInspectorW = Math.min(360, Math.max(180, width))
                }
                visible: root.showMidInspector; clip: true

                Rectangle {
                    anchors.fill: parent
                    color: theme.colors.panelBackground
                    border.color: theme.colors.borderHard; border.width: 1

                    ColumnLayout {
                        anchors.fill: parent; spacing: 0
                        Rectangle {
                            Layout.fillWidth: true; height: 32
                            color: theme.colors.surfaceRaised
                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: 10
                                text: qsTr("INSPECTOR")
                                color: theme.colors.textDisabled
                                font.pixelSize: theme.typography.micro
                                font.letterSpacing: theme.typography.letterSpacingCaps
                                font.weight: Font.Bold
                            }
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle }
                        }
                        InspectorPanel { Layout.fillWidth: true; Layout.fillHeight: true }
                    }
                }
            }

            // ── Right: AI panel ────────────────────────────────────────────
            Item {
                id: rightPane
                SplitView.minimumWidth:  !root.showRightColumn ? 0 : (root.rightExpanded ? 320 : 38)
                SplitView.preferredWidth: !root.showRightColumn ? 0 : (root.rightExpanded ? Math.max(360, root.rightDockW) : 38)
                SplitView.maximumWidth:  !root.showRightColumn ? 0 : (root.rightExpanded ? 680 : 40)
                onWidthChanged: {
                    if (root.showRightColumn && root.rightExpanded && width > 50)
                        root.rightDockW = Math.min(680, Math.max(320, width))
                }
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: root.showRightColumn && root.rightExpanded ? theme.colors.aiPanelDeep : theme.colors.panelBackground
                    border.color: root.showRightColumn ? theme.colors.chromeEdge : "transparent"
                    border.width: root.showRightColumn ? 1 : 0

                    // Collapsed rail
                    Rectangle {
                        visible: root.showRightColumn && !root.rightExpanded
                        anchors.fill: parent
                        color: theme.colors.timelineBg
                        border.color: theme.colors.borderSubtle
                        border.width: 0

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            anchors.topMargin: 8

                            ToolButton {
                                Layout.alignment: Qt.AlignHCenter
                                width: 28
                                height: 28
                                text: "\u203a"
                                font.pixelSize: 18
                                flat: true
                                ToolTip.text: qsTr("Expand AI panel"); ToolTip.visible: hovered
                                onClicked: root.rightExpanded = true
                                background: Rectangle {
                                    radius: 4
                                    color: parent.hovered ? theme.colors.accentMuted : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text; font: parent.font; color: theme.colors.accent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 10
                                width: 8
                                height: 8
                                radius: 4
                                color: mainWindow && mainWindow.aiBusy ? theme.colors.warning : theme.colors.success
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: theme.colors.borderSoft
                        }
                    }

                    // Expanded — AI assistant (full height)
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        visible: root.showRightColumn && root.rightExpanded

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            color: theme.colors.surfaceRaised

                            Rectangle {
                                anchors.top: parent.top
                                width: parent.width
                                height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.35; color: theme.colors.chromeEdge }
                                    GradientStop { position: 0.65; color: theme.colors.accent }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 6
                                spacing: 8

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: mainWindow && mainWindow.aiBusy ? theme.colors.warning : theme.colors.success
                                    border.width: 1
                                    border.color: theme.colors.borderSoft
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    text: qsTr("AI ASSISTANT")
                                    color: theme.colors.accentText
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1.2
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    height: 18
                                    width: modelBadgeText.implicitWidth + 12
                                    radius: 9
                                    color: theme.colors.accentMuted
                                    border.color: theme.colors.borderSoft
                                    border.width: 1
                                    Layout.alignment: Qt.AlignVCenter
                                    Text {
                                        id: modelBadgeText
                                        anchors.centerIn: parent
                                        text: qsTr("Assistant")
                                        font.pixelSize: 9
                                        font.weight: Font.Medium
                                        color: theme.colors.accent
                                    }
                                }

                                ToolButton {
                                    id: aiCollapseBtn
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    flat: true
                                    text: "\u2039"
                                    font.pixelSize: 16
                                    font.weight: Font.Light
                                    ToolTip.text: qsTr("Collapse panel"); ToolTip.visible: hovered
                                    onClicked: root.rightExpanded = false
                                    background: Rectangle {
                                        color: aiCollapseBtn.hovered ? theme.colors.chromePopupHover : "transparent"
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: aiCollapseBtn.text
                                        font: aiCollapseBtn.font
                                        color: theme.colors.textSecondary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: theme.colors.borderSubtle
                            }
                        }

                        AIPromptPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            onCloseRequested: root.rightExpanded = false
                        }
                    }
                }
            }
        }
    }

    Repeater {
        model: floatingPanels
        delegate: Window {
            required property int index
            required property int panelId
            required property string panelName
            required property int posX
            required property int posY
            required property int widthPx
            required property int heightPx

            title: panelName
            visible: true
            minimumWidth: 280
            minimumHeight: 220
            width: widthPx
            height: heightPx
            x: posX
            y: posY
            color: theme.colors.panelBackground
            onXChanged: if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "posX", x)
            onYChanged: if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "posY", y)
            onWidthChanged: if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "widthPx", width)
            onHeightChanged: if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "heightPx", height)

            onClosing: function(closeEvent) {
                closeEvent.accepted = false
                root.redockFloating(index)
            }

            Rectangle {
                anchors.fill: parent
                color: theme.colors.panelBackground
                border.color: theme.colors.borderSoft
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        color: theme.colors.surfaceRaised
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            Label {
                                text: panelName
                                color: theme.colors.textPrimary
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }
                            Item { Layout.fillWidth: true }
                            ToolButton {
                                text: qsTr("Dock")
                                onClicked: root.redockFloating(index)
                            }
                        }
                    }
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: root.panelSourceComponent(panelId)
                    }
                }
            }
        }
    }
}
