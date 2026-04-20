import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import Fognitix

// ═══════════════════════════════════════════════════════════════════════════
//  EditorChrome — Fognitix NLE
//
//  ┌─ DESIGN TOKENS ────────────────────────────────────────────────────────
//  │  All colours live in the `tok` object below. To retheme the entire
//  │  app, only edit that one block — nothing else needs to change.
//  │
//  │  Palette (from reference swatch):
//  │    #262626  surfaceMid    — panel tabs, quick-rail bg
//  │    #242424  surfaceLow    — left dock body
//  │    #1C1C1C  base          — main app background
//  │    #1A1A1A  deep          — timeline, AI panel bg
//  │    #171717  deepest       — preview area, darkest surfaces
//  │
//  │  Text uses white at strict opacity levels — no grey hex codes.
//  │  Borders are white-at-opacity hairlines — no grey hex codes.
//  │  Accent is #E8E8E8 (near-white) — zero chromatic hue anywhere.
//  └────────────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

Item {
    id: root
    anchors.fill: parent

    // ╔═══════════════════════════════════════════════════════════════════╗
    // ║  DESIGN TOKENS  —  edit here to retheme everything               ║
    // ╚═══════════════════════════════════════════════════════════════════╝
    QtObject {
        id: tok

        // ── Surface ramp (darkest → lightest) ────────────────────────────
        //    Change these six lines to repaint every surface in the app.
        readonly property color deepest      : "#171717"   // preview bg
        readonly property color deep         : "#1A1A1A"   // timeline / AI panel
        readonly property color base         : "#1C1C1C"   // main app background
        readonly property color panelBg      : "#111111"   // inner panel bg (darker inset)
        readonly property color surfaceLow   : "#242424"   // left dock body
        readonly property color surfaceMid   : "#262626"   // tab bar, rail
        readonly property color surfaceHigh  : "#2e2e2e"   // hover state

        // ── Border hairlines (white at opacity) ───────────────────────────
        //    Adjust the alpha to make separators more or less visible.
        readonly property color borderFaint  : Qt.rgba(1, 1, 1, 0.05)
        readonly property color borderSubtle : Qt.rgba(1, 1, 1, 0.09)
        readonly property color borderNormal : Qt.rgba(1, 1, 1, 0.13)
        readonly property color borderStrong : Qt.rgba(1, 1, 1, 0.20)
        readonly property color borderFocus  : Qt.rgba(1, 1, 1, 0.45)

        // ── Text (white at opacity) ────────────────────────────────────────
        //    Four levels. Only touch the alpha values.
        readonly property color textPrimary  : Qt.rgba(1, 1, 1, 0.92)
        readonly property color textSec      : Qt.rgba(1, 1, 1, 0.52)
        readonly property color textMuted    : Qt.rgba(1, 1, 1, 0.30)
        readonly property color textDisabled : Qt.rgba(1, 1, 1, 0.18)

        // ── Accent ────────────────────────────────────────────────────────
        //    Single near-white accent. Swap to e.g. "#d4b896" for warm tint.
        readonly property color accent       : "#e8e8e8"
        readonly property color accentMuted  : Qt.rgba(1, 1, 1, 0.07)
        readonly property color accentStrong : "#ffffff"

        // ── Status dots ───────────────────────────────────────────────────
        readonly property color statusIdle   : Qt.rgba(1, 1, 1, 0.28)   // AI idle
        readonly property color statusBusy   : "#c8a96e"                 // AI working — warm amber, only coloured dot

        // ── Typography ────────────────────────────────────────────────────
        readonly property int    fontSizeXS  : 9
        readonly property int    fontSizeSM  : 10
        readonly property int    fontSizeMD  : 11
        readonly property int    fontSizeLG  : 12
        readonly property string fontFamily  : "Inter, SF Pro Display, system-ui"

        // ── Geometry ──────────────────────────────────────────────────────
        readonly property int chromeH   : 40    // top bar height
        readonly property int railH     : 28    // quick-dock rail height
        readonly property int tabH      : 32    // panel tab bar height
        readonly property int radius    : 5     // control corner radius
        readonly property int radiusSM  : 3
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Layout geometry
    // ═══════════════════════════════════════════════════════════════════════
    property int  leftDockInnerW:   300
    property int  topLeftDockH:     220
    property int  centerTopLeftW:   320
    property int  midInspectorW:    240
    property int  rightDockW:       460
    property bool showLeftBody:     true
    property bool showMidInspector: false
    property bool showRightColumn:  true
    property bool rightExpanded:    true
    property real previewRatio:     0.60

    // ── Tool / snap state ─────────────────────────────────────────────────
    property int  activeTool:  0
    property bool snapEnabled: false
    readonly property var toolNames: [
        qsTr("Selection"), qsTr("Pen"), qsTr("Razor"), qsTr("Ripple Edit"),
        qsTr("Rolling Edit"), qsTr("Slip"), qsTr("Slide"), qsTr("Hand"), qsTr("Zoom")
    ]

    property var openImportFn: null
    property var openExportFn: null

    PanelRegistry { id: panelCatalog }
    readonly property var panelRegistry: panelCatalog.panels

    ListModel { id: leftActivePanels }
    ListModel { id: topLeftActivePanels }
    ListModel { id: centerTopActivePanels }
    ListModel { id: floatingPanels }
    property int leftCurrentId: 0
    property int topLeftCurrentId: -1
    property int centerTopCurrentId: -1

    // ── Panel menu item list ──────────────────────────────────────────────
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

    // ── Panel management ──────────────────────────────────────────────────
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
        if (fromIdx < 0 || fromIdx >= leftActivePanels.count) return
        const c = Math.max(0, Math.min(leftActivePanels.count - 1, toIdx))
        if (c !== fromIdx) leftActivePanels.move(fromIdx, c, 1)
    }

    function movePanel(panelId, delta) {
        for (let i = 0; i < leftActivePanels.count; i++) {
            if (leftActivePanels.get(i).panelId === panelId) {
                movePanelByIndex(i, i + delta); return
            }
        }
    }

    function panelById(panelId) { return panelRegistry.find(x => x.id === panelId) }
    function _isPanelActiveIn(modelRef, panelId) {
        for (let i = 0; i < modelRef.count; i++)
            if (modelRef.get(i).panelId === panelId) return true
        return false
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
        if (!panel) return
        removePanel(panelId)
        floatingPanels.append({
            panelId: panelId, panelName: panel.name,
            posX: 180 + floatingPanels.count * 24,
            posY: 120 + floatingPanels.count * 24,
            widthPx: 460, heightPx: 360
        })
    }

    function redockFloating(index) {
        if (index < 0 || index >= floatingPanels.count) return
        const row = floatingPanels.get(index)
        floatingPanels.remove(index)
        addPanel(row.panelId)
        showLeftBody = true
    }

    function isPanelActive(panelId) {
        return _isPanelActiveIn(leftActivePanels, panelId)
    }

    function addTopLeftPanel(panelId) {
        for (let i = 0; i < topLeftActivePanels.count; i++) {
            if (topLeftActivePanels.get(i).panelId === panelId) {
                topLeftCurrentId = panelId
                return
            }
        }
        const p = panelById(panelId)
        if (p) {
            topLeftActivePanels.append({ panelId: panelId, panelName: p.name })
            topLeftCurrentId = panelId
        }
    }
    function removeTopLeftPanel(panelId) {
        for (let i = 0; i < topLeftActivePanels.count; i++) {
            if (topLeftActivePanels.get(i).panelId === panelId) {
                topLeftActivePanels.remove(i)
                if (topLeftCurrentId === panelId) {
                    if (topLeftActivePanels.count > 0)
                        topLeftCurrentId = topLeftActivePanels.get(Math.max(0, Math.min(i, topLeftActivePanels.count - 1))).panelId
                    else
                        topLeftCurrentId = -1
                }
                return
            }
        }
    }
    function moveTopLeftPanelByIndex(fromIdx, toIdx) {
        if (fromIdx < 0 || fromIdx >= topLeftActivePanels.count) return
        const c = Math.max(0, Math.min(topLeftActivePanels.count - 1, toIdx))
        if (c !== fromIdx) topLeftActivePanels.move(fromIdx, c, 1)
    }

    function addCenterTopPanel(panelId) {
        for (let i = 0; i < centerTopActivePanels.count; i++) {
            if (centerTopActivePanels.get(i).panelId === panelId) {
                centerTopCurrentId = panelId
                return
            }
        }
        const p = panelById(panelId)
        if (p) {
            centerTopActivePanels.append({ panelId: panelId, panelName: p.name })
            centerTopCurrentId = panelId
        }
    }
    function removeCenterTopPanel(panelId) {
        for (let i = 0; i < centerTopActivePanels.count; i++) {
            if (centerTopActivePanels.get(i).panelId === panelId) {
                centerTopActivePanels.remove(i)
                if (centerTopCurrentId === panelId) {
                    if (centerTopActivePanels.count > 0)
                        centerTopCurrentId = centerTopActivePanels.get(Math.max(0, Math.min(i, centerTopActivePanels.count - 1))).panelId
                    else
                        centerTopCurrentId = -1
                }
                return
            }
        }
    }
    function moveCenterTopPanelByIndex(fromIdx, toIdx) {
        if (fromIdx < 0 || fromIdx >= centerTopActivePanels.count) return
        const c = Math.max(0, Math.min(centerTopActivePanels.count - 1, toIdx))
        if (c !== fromIdx) centerTopActivePanels.move(fromIdx, c, 1)
    }

    function _syncPlaceholderMeta() {
        if (!leftDockPhLoader.item) return
        const p = panelRegistry.find(x => x.id === leftCurrentId)
        leftDockPhLoader.item.panelTitle    = p ? p.name     : ""
        leftDockPhLoader.item.panelCategory = p ? p.category : ""
    }

    // ── Public API ────────────────────────────────────────────────────────
    function focusAI()           { showRightColumn = true; rightExpanded = true }
    function focusEffectsPanel() { openLeftDockPanel(6) }

    function openLeftDockPanel(panelId) {
        showLeftBody = true
        addPanel(panelId)
    }

    function openMidInspector() { showMidInspector = true }

    function resetWindowLayout() {
        leftDockInnerW = 300; midInspectorW = 240; rightDockW = 460
        topLeftDockH = 220; centerTopLeftW = 320
        showLeftBody = true; showMidInspector = false
        showRightColumn = true; rightExpanded = true; previewRatio = 0.60
        leftActivePanels.clear()
        leftActivePanels.append({ panelId: 0, panelName: "Project" })
        leftActivePanels.append({ panelId: 1, panelName: "Media" })
        leftCurrentId = 1
        topLeftActivePanels.clear()
        topLeftCurrentId = -1
        centerTopActivePanels.clear()
        centerTopCurrentId = -1
        floatingPanels.clear()
    }

    function emphasizePreview()  { previewRatio = Math.min(0.82, Math.max(0.48, previewRatio + 0.1)) }
    function emphasizeTimeline() { previewRatio = Math.max(0.42, previewRatio - 0.1) }

    function syncToolName() {
        if (mainWindow) {
            const n = toolNames[Math.max(0, Math.min(activeTool, toolNames.length - 1))]
            mainWindow.setUiToolName(n)
        }
    }
    onActiveToolChanged: syncToolName()

    // ── Lifecycle ─────────────────────────────────────────────────────────
    Component.onCompleted: {
        if (mainWindow) {
            const L = mainWindow.loadEditorLayout()
            if (L.leftInner    !== undefined) leftDockInnerW   = Math.max(200, Math.min(420, L.leftInner))
            if (L.midW         !== undefined) midInspectorW    = Math.max(180, Math.min(360, L.midW))
            if (L.rightW       !== undefined) rightDockW       = Math.max(320, Math.min(680, L.rightW))
            if (L.topLeftH     !== undefined) topLeftDockH     = Math.max(140, Math.min(520, Number(L.topLeftH)))
            if (L.centerTopLeftW !== undefined) centerTopLeftW = Math.max(220, Math.min(640, Number(L.centerTopLeftW)))
            if (L.showLeftBody !== undefined) showLeftBody     = L.showLeftBody
            if (L.showMid      !== undefined) showMidInspector = L.showMid
            if (L.showRight    !== undefined) showRightColumn  = L.showRight
            if (L.previewRatio !== undefined) {
                const r = Number(L.previewRatio)
                if (!isNaN(r)) previewRatio = Math.min(0.85, Math.max(0.45, r))
            }
            if (L.leftPanelIds !== undefined) {
                const ids = String(L.leftPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                leftActivePanels.clear()
                for (const pid of ids) {
                    const p = panelById(pid)
                    if (p) leftActivePanels.append({ panelId: p.id, panelName: p.name })
                }
                if (leftActivePanels.count === 0) {
                    leftActivePanels.append({ panelId: 0, panelName: "Project" })
                    leftActivePanels.append({ panelId: 1, panelName: "Media" })
                }
            }
            if (L.leftCurrentId !== undefined) leftCurrentId = Number(L.leftCurrentId)
            if (L.topLeftPanelIds !== undefined) {
                const ids2 = String(L.topLeftPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                topLeftActivePanels.clear()
                for (const pid of ids2) {
                    const p = panelById(pid)
                    if (p) topLeftActivePanels.append({ panelId: p.id, panelName: p.name })
                }
            }
            if (L.topLeftCurrentId !== undefined) topLeftCurrentId = Number(L.topLeftCurrentId)
            if (L.centerTopPanelIds !== undefined) {
                const ids3 = String(L.centerTopPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                centerTopActivePanels.clear()
                for (const pid of ids3) {
                    const p = panelById(pid)
                    if (p) centerTopActivePanels.append({ panelId: p.id, panelName: p.name })
                }
            }
            if (L.centerTopCurrentId !== undefined) centerTopCurrentId = Number(L.centerTopCurrentId)
            if (L.floatingPanelsJson !== undefined && String(L.floatingPanelsJson).length > 0) {
                let rows = []
                try { rows = JSON.parse(String(L.floatingPanelsJson)) } catch (e) { rows = [] }
                for (const row of rows) {
                    const p = panelById(Number(row.panelId))
                    if (!p) continue
                    floatingPanels.append({
                        panelId: p.id, panelName: p.name,
                        posX: Number(row.posX) || 220, posY: Number(row.posY) || 160,
                        widthPx: Number(row.widthPx) || 460, heightPx: Number(row.heightPx) || 360
                    })
                }
            } else if (L.floatingPanelIds !== undefined) {
                const fids = String(L.floatingPanelIds).split(",").map(s => Number(s)).filter(n => !isNaN(n) && n >= 0)
                for (const pid of fids) {
                    const p = panelById(pid)
                    if (p) floatingPanels.append({ panelId: p.id, panelName: p.name, posX: 220, posY: 160, widthPx: 460, heightPx: 360 })
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
        if (!_isPanelActiveIn(topLeftActivePanels, topLeftCurrentId))
            topLeftCurrentId = topLeftActivePanels.count > 0 ? topLeftActivePanels.get(0).panelId : -1
        if (!_isPanelActiveIn(centerTopActivePanels, centerTopCurrentId))
            centerTopCurrentId = centerTopActivePanels.count > 0 ? centerTopActivePanels.get(0).panelId : -1
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

    function collectLayoutMap(skipLive) {
        let pr = previewRatio
        if (!skipLive && centerSplit.height > 80 && pvSlot.height > 40)
            pr = Math.min(0.85, Math.max(0.45, pvSlot.height / centerSplit.height))
        const panelIds = [], topLeftPanelIds = [], centerTopPanelIds = [], floatingIds = [], floatingRows = []
        for (let i = 0; i < leftActivePanels.count; i++)  panelIds.push(leftActivePanels.get(i).panelId)
        for (let i = 0; i < topLeftActivePanels.count; i++) topLeftPanelIds.push(topLeftActivePanels.get(i).panelId)
        for (let i = 0; i < centerTopActivePanels.count; i++) centerTopPanelIds.push(centerTopActivePanels.get(i).panelId)
        for (let i = 0; i < floatingPanels.count; i++) {
            const r = floatingPanels.get(i)
            floatingIds.push(r.panelId)
            floatingRows.push({ panelId: r.panelId, panelName: r.panelName, posX: r.posX, posY: r.posY, widthPx: r.widthPx, heightPx: r.heightPx })
        }
        return {
            leftInner: leftDockInnerW, midW: midInspectorW, rightW: rightDockW,
            topLeftH: topLeftDockH, centerTopLeftW: centerTopLeftW,
            showLeftBody, showMid: showMidInspector, showRight: showRightColumn, previewRatio: pr,
            leftPanelIds: panelIds.join(","), leftCurrentId,
            topLeftPanelIds: topLeftPanelIds.join(","), topLeftCurrentId,
            centerTopPanelIds: centerTopPanelIds.join(","), centerTopCurrentId,
            floatingPanelIds: floatingIds.join(","),
            floatingPanelsJson: JSON.stringify(floatingRows)
        }
    }

    onLeftDockInnerWChanged:   scheduleSaveLayout()
    onMidInspectorWChanged:    scheduleSaveLayout()
    onRightDockWChanged:       scheduleSaveLayout()
    onTopLeftDockHChanged:     scheduleSaveLayout()
    onCenterTopLeftWChanged:   scheduleSaveLayout()
    onShowLeftBodyChanged:     scheduleSaveLayout()
    onShowMidInspectorChanged: scheduleSaveLayout()
    onShowRightColumnChanged:  scheduleSaveLayout()
    onRightExpandedChanged:    scheduleSaveLayout()
    onPreviewRatioChanged:     scheduleSaveLayout()

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

    // ═══════════════════════════════════════════════════════════════════════
    // Panel source components
    // ═══════════════════════════════════════════════════════════════════════
    Component { id: compProject;        ProjectPanel {} }
    Component { id: compMediaPool;      MediaPoolPanel {} }
    Component { id: compMediaBrowser;   MediaBrowserPanel {} }
    Component { id: compLibrary;        LibraryPanel {} }
    Component { id: compFootageInfo;    FootageInfoPanel {} }
    Component { id: compMetadata;       MetadataPanel {} }
    Component { id: compEffectsBrowser; EffectsBrowser {} }
    Component { id: compEffectsPanel;   EffectsPanel {} }
    Component { id: compTransitions;    TransitionsPanel {} }
    Component { id: compEssentialGfx;   EssentialGraphicsPanel {} }
    Component { id: compContentAware;   ContentAwareFillPanel {} }
    Component { id: compColor;          ColorPanel {} }
    Component { id: compLumetriScopes;  LumetriScopesPanel {} }
    Component { id: compCharacter;      CharacterPanel {} }
    Component { id: compParagraph;      ParagraphPanel {} }
    Component { id: compMotionSketch;   MotionSketchPanel {} }
    Component { id: compGraphEditor;    GraphEditorPanel {} }
    Component { id: compMaskInterp;     MaskInterpolationPanel {} }
    Component { id: compSmoother;       SmootherPanel {} }
    Component { id: compTracker;        TrackerPanel {} }
    Component { id: compThreeD;         ThreeDPanel {} }
    Component { id: compFlowchart;      FlowchartPanel {} }
    Component { id: compAudioMixer;     AudioMixerPanel {} }
    Component { id: compAlign;          AlignPanel {} }
    Component { id: compMarkers;        MarkersPanel {} }
    Component { id: compHistory;        HistoryPanel {} }
    Component { id: compRenderQueue;    RenderQueuePanel {} }
    Component { id: compInspector;      InspectorPanel {} }
    Component { id: compInfo;           InfoPanel {} }
    Component { id: compPlaceholder;    PanelPlaceholder {} }

    function panelSourceComponent(panelId) {
        switch (panelId) {
            case  0: return compProject
            case  1: return compMediaPool
            case  2: return compMediaBrowser
            case  3: return compLibrary
            case  4: return compFootageInfo
            case  5: return compMetadata
            case  6: return compEffectsBrowser
            case  7: return compEffectsPanel
            case  8: return compTransitions
            case  9: return compEssentialGfx
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

    // ═══════════════════════════════════════════════════════════════════════
    // "Add Panel" popup
    // ═══════════════════════════════════════════════════════════════════════
    Popup {
        id: addPanelPopup
        width: 240
        height: Math.min(520, panelMenuListView.contentHeight + 2)
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: tok.surfaceMid
            border.color: tok.borderNormal
            border.width: 1
            radius: tok.radius
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
                height: modelData.type === "header" ? 22 : 26
                sourceComponent: modelData.type === "header" ? catHeaderComp : panelItemComp
            }
        }
    }

    component CatHeader: Item {
        required property var modelData
        height: 22
        Rectangle { anchors.fill: parent; color: tok.deep }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: 10
            text: modelData.text.toUpperCase()
            color: tok.textDisabled
            font.pixelSize: tok.fontSizeXS
            font.weight: Font.Medium
            font.letterSpacing: 0.9
            font.family: tok.fontFamily
        }
    }

    component PanelMenuItem: Item {
        id: pmItem
        required property var modelData
        height: 26
        HoverHandler { id: pmHover }
        Rectangle {
            anchors.fill: parent
            color: pmHover.containsMouse ? tok.surfaceHigh : "transparent"
        }
        Row {
            anchors.fill: parent
            anchors.leftMargin: 18; anchors.rightMargin: 8
            spacing: 6
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.isPanelActive(pmItem.modelData.id) ? "✓" : ""
                color: tok.textPrimary
                font.pixelSize: tok.fontSizeSM
                font.family: tok.fontFamily
                width: 12
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pmItem.modelData.name
                color: root.isPanelActive(pmItem.modelData.id) ? tok.textPrimary : tok.textSec
                font.pixelSize: tok.fontSizeMD
                font.family: tok.fontFamily
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.addPanel(pmItem.modelData.id)
        }
    }

    Component { id: catHeaderComp; CatHeader {} }
    Component { id: panelItemComp; PanelMenuItem {} }

    // ═══════════════════════════════════════════════════════════════════════
    // ROOT LAYOUT
    // ═══════════════════════════════════════════════════════════════════════
    Rectangle {
        anchors.fill: parent
        color: tok.base

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ╔═════════════════════════════════════════════════════════════╗
            // ║  TOP CHROME BAR                                             ║
            // ╚═════════════════════════════════════════════════════════════╝
            Rectangle {
                Layout.fillWidth: true
                height: tok.chromeH
                color: tok.surfaceMid

                // Bottom separator
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1
                    color: tok.borderNormal
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 0

                    // ── Import / Edit / Export segmented control ───────────
                    Row {
                        spacing: 0
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            width: segRow.implicitWidth + 2
                            height: 26
                            radius: tok.radius
                            color: tok.deep
                            border.color: tok.borderNormal
                            border.width: 1

                            Row {
                                id: segRow
                                anchors.centerIn: parent
                                spacing: 0

                                // Import
                                Item {
                                    width: 60; height: 26
                                    HoverHandler { id: importHover }
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: tok.radiusSM
                                        color: importHover.hovered ? tok.surfaceHigh : "transparent"
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("Import")
                                        color: tok.textSec
                                        font.pixelSize: tok.fontSizeMD
                                        font.family: tok.fontFamily
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.openImportFn) root.openImportFn()
                                    }
                                }

                                Rectangle { width: 1; height: 14; color: tok.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

                                // Edit — active state
                                Item {
                                    width: 52; height: 26
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: tok.radiusSM
                                        color: tok.surfaceHigh
                                        border.color: tok.borderStrong
                                        border.width: 1
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("Edit")
                                        color: tok.textPrimary
                                        font.pixelSize: tok.fontSizeMD
                                        font.family: tok.fontFamily
                                        font.weight: Font.Medium
                                    }
                                }

                                Rectangle { width: 1; height: 14; color: tok.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

                                // Export
                                Item {
                                    width: 62; height: 26
                                    HoverHandler { id: exportHover }
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: tok.radiusSM
                                        color: exportHover.hovered ? tok.surfaceHigh : "transparent"
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("Export")
                                        color: tok.textSec
                                        font.pixelSize: tok.fontSizeMD
                                        font.family: tok.fontFamily
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.openExportFn) root.openExportFn()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { width: 1; height: 16; color: tok.borderSubtle; Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 10; Layout.rightMargin: 10 }

                    // Project name
                    Text {
                        text: mainWindow ? mainWindow.projectName : qsTr("Untitled Project")
                        color: tok.textPrimary
                        font.pixelSize: tok.fontSizeMD
                        font.family: tok.fontFamily
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                        Layout.maximumWidth: 180
                    }

                    Rectangle { width: 1; height: 14; color: tok.borderFaint; Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 8; Layout.rightMargin: 8 }

                    Text {
                        text: qsTr("%1 tracks · %2 clips")
                            .arg(mainWindow ? mainWindow.trackCount : 0)
                            .arg(mainWindow ? mainWindow.clipCount  : 0)
                        color: tok.textDisabled
                        font.pixelSize: tok.fontSizeXS
                        font.family: tok.fontFamily
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // ── Panel visibility toggles ───────────────────────────
                    Row {
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Repeater {
                            model: [
                                { label: qsTr("Panels"),    idx: 0 },
                                { label: qsTr("Inspector"), idx: 1 },
                                { label: qsTr("AI Chat"),   idx: 2 }
                            ]
                            delegate: Item {
                                required property var modelData
                                required property int index
                                width: toggleText.implicitWidth + 18; height: 24

                                readonly property bool isOn: index === 0 ? root.showLeftBody
                                                           : index === 1 ? root.showMidInspector
                                                           : root.showRightColumn
                                HoverHandler { id: toggleHover }

                                Rectangle {
                                    anchors.fill: parent; radius: tok.radiusSM
                                    color: parent.isOn ? tok.surfaceHigh
                                         : toggleHover.hovered ? Qt.rgba(1,1,1,0.04) : "transparent"
                                    border.color: parent.isOn ? tok.borderStrong : "transparent"
                                    border.width: 1
                                }
                                Text {
                                    id: toggleText
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pixelSize: tok.fontSizeSM
                                    font.family: tok.fontFamily
                                    color: parent.isOn ? tok.textPrimary : tok.textMuted
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (index === 0) root.showLeftBody = !root.showLeftBody
                                        else if (index === 1) root.showMidInspector = !root.showMidInspector
                                        else root.showRightColumn = !root.showRightColumn
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { width: 1; height: 16; color: tok.borderSubtle; Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 8; Layout.rightMargin: 8 }

                    // ── AI Agent indicator ─────────────────────────────────
                    Item {
                        width: aiAgentRow.implicitWidth + 20; height: 26
                        Layout.alignment: Qt.AlignVCenter
                        HoverHandler { id: aiHover }

                        Rectangle {
                            anchors.fill: parent; radius: tok.radius
                            color: aiHover.hovered ? tok.surfaceHigh : tok.deep
                            border.color: aiHover.hovered ? tok.borderStrong : tok.borderNormal
                            border.width: 1
                        }
                        Row {
                            id: aiAgentRow
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: mainWindow && mainWindow.aiBusy ? tok.statusBusy : tok.statusIdle
                            }
                            Text {
                                text: qsTr("AI Agent")
                                color: tok.textSec
                                font.pixelSize: tok.fontSizeSM
                                font.family: tok.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.focusAI()
                        }
                    }

                    Rectangle { width: 1; height: 16; color: tok.borderSubtle; Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 8; Layout.rightMargin: 8 }

                    // ── Workspace + Preview quality ────────────────────────
                    Row {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        ComboBox {
                            id: wsCombo
                            implicitHeight: 26; implicitWidth: 112
                            padding: 0; leftPadding: 8; rightPadding: 24
                            model: [qsTr("Standard"), qsTr("Editing"), qsTr("Color"), qsTr("Motion Tracking"), qsTr("VFX")]
                            font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily
                            hoverEnabled: true
                            ToolTip.text: qsTr("Workspace layout"); ToolTip.visible: hovered

                            delegate: ItemDelegate {
                                required property int index
                                width: wsCombo.width; implicitHeight: 26
                                text: wsCombo.textAt(index)
                                background: Rectangle { color: parent.highlighted ? tok.surfaceHigh : tok.surfaceMid }
                                contentItem: Text {
                                    text: parent.text; font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily
                                    color: tok.textPrimary; verticalAlignment: Text.AlignVCenter; leftPadding: 8
                                }
                            }
                            background: Rectangle {
                                radius: tok.radiusSM
                                color: wsCombo.down || wsCombo.popup.opened ? tok.surfaceHigh : tok.deep
                                border.color: wsCombo.popup.opened ? tok.borderStrong : tok.borderNormal
                                border.width: 1
                            }
                            contentItem: Text {
                                text: wsCombo.displayText; font: wsCombo.font
                                color: tok.textSec; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                            }
                            indicator: Text {
                                x: wsCombo.width - 18; anchors.verticalCenter: parent.verticalCenter
                                text: "⌄"; font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily; color: tok.textDisabled
                            }
                            function syncWsIndex() {
                                if (!mainWindow) return
                                for (let i = 0; i < count; ++i) { if (textAt(i) === mainWindow.workspace) { currentIndex = i; return } }
                                currentIndex = 0
                            }
                            Component.onCompleted: syncWsIndex()
                            Connections { target: mainWindow; function onWorkspaceChanged() { wsCombo.syncWsIndex() } }
                            onActivated: (i) => { if (mainWindow && i >= 0 && i < count) mainWindow.workspace = textAt(i) }
                        }

                        ComboBox {
                            id: pqCombo
                            implicitHeight: 26; implicitWidth: 76
                            padding: 0; leftPadding: 8; rightPadding: 22
                            model: [qsTr("Full"), qsTr("Half"), qsTr("Quarter")]
                            font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily
                            hoverEnabled: true
                            ToolTip.text: qsTr("Preview resolution"); ToolTip.visible: hovered

                            delegate: ItemDelegate {
                                required property int index
                                width: pqCombo.width; implicitHeight: 26
                                text: pqCombo.textAt(index)
                                background: Rectangle { color: parent.highlighted ? tok.surfaceHigh : tok.surfaceMid }
                                contentItem: Text {
                                    text: parent.text; font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily
                                    color: tok.textSec; verticalAlignment: Text.AlignVCenter; leftPadding: 8
                                }
                            }
                            background: Rectangle {
                                radius: tok.radiusSM
                                color: pqCombo.down || pqCombo.popup.opened ? tok.surfaceHigh : tok.deep
                                border.color: pqCombo.popup.opened ? tok.borderStrong : tok.borderNormal
                                border.width: 1
                            }
                            contentItem: Text {
                                text: pqCombo.displayText; font: pqCombo.font
                                color: tok.textSec; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                            }
                            indicator: Text {
                                x: pqCombo.width - 16; anchors.verticalCenter: parent.verticalCenter
                                text: "⌄"; font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily; color: tok.textDisabled
                            }
                            function syncPqIndex() {
                                if (!mainWindow) return
                                for (let i = 0; i < count; ++i) { if (textAt(i) === mainWindow.previewQuality) { currentIndex = i; return } }
                                currentIndex = 0
                            }
                            Component.onCompleted: syncPqIndex()
                            Connections { target: mainWindow; function onPreviewQualityChanged() { pqCombo.syncPqIndex() } }
                            onActivated: (i) => { if (mainWindow && i >= 0 && i < count) mainWindow.previewQuality = textAt(i) }
                        }
                    }

                    Rectangle { width: 1; height: 16; color: tok.borderSubtle; Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 8; Layout.rightMargin: 8 }

                    // ── Settings ───────────────────────────────────────────
                    Item {
                        width: 68; height: 26
                        Layout.alignment: Qt.AlignVCenter
                        HoverHandler { id: settingsHover }
                        Rectangle {
                            anchors.fill: parent; radius: tok.radiusSM
                            color: settingsHover.hovered ? tok.surfaceHigh : tok.deep
                            border.color: settingsHover.hovered ? tok.borderStrong : tok.borderNormal
                            border.width: 1
                        }
                        Text {
                            anchors.centerIn: parent; text: qsTr("Settings")
                            color: tok.textSec; font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = root
                                while (p) {
                                    if (typeof p.openSettingsWindow === "function") { p.openSettingsWindow(); break }
                                    p = p.parent
                                }
                            }
                        }
                    }

                    // ── User avatar ────────────────────────────────────────
                    Item {
                        width: 26; height: 26
                        Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 4
                        HoverHandler { id: userHover }
                        Rectangle {
                            anchors.fill: parent; radius: 13
                            color: userHover.hovered ? tok.surfaceHigh : tok.surfaceLow
                            border.color: userHover.hovered ? tok.borderStrong : tok.borderNormal
                            border.width: 1
                        }
                        Text {
                            anchors.centerIn: parent; text: "U"
                            font.pixelSize: tok.fontSizeSM; font.family: tok.fontFamily; font.weight: Font.Medium
                            color: tok.textSec
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }

            // ╔═════════════════════════════════════════════════════════════╗
            // ║  MAIN SPLIT VIEW                                            ║
            // ╚═════════════════════════════════════════════════════════════╝
            SplitView {
                id: mainHSplit
                orientation: Qt.Horizontal
                Layout.fillWidth: true
                Layout.fillHeight: true

                handle: Item {
                    implicitWidth: 1
                    Rectangle {
                        anchors.centerIn: parent; width: 1; height: parent.height
                        color: SplitHandle.pressed ? tok.borderFocus
                             : SplitHandle.hovered ? tok.borderStrong : tok.borderNormal
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }

                // ── LEFT DOCK ─────────────────────────────────────────────
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
                        color: tok.surfaceLow

                        Rectangle {
                            anchors.right: parent.right; width: 1; height: parent.height
                            color: tok.borderNormal
                        }

                        SplitView {
                            anchors.fill: parent
                            orientation: Qt.Vertical

                            Item {
                                SplitView.minimumHeight: 140
                                SplitView.preferredHeight: root.topLeftDockH
                                SplitView.maximumHeight: 560
                                onHeightChanged: if (height > 20) root.topLeftDockH = Math.max(140, Math.min(560, height))

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    DockTabStack {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: tok.tabH + 2
                                        panelsModel: topLeftActivePanels
                                        currentPanelId: root.topLeftCurrentId
                                        panelMenuItems: root.panelMenuItems
                                        isPanelActiveFn: function(pid) { return root._isPanelActiveIn(topLeftActivePanels, pid) }
                                        onSelectPanelFn: function(panelId) { root.topLeftCurrentId = panelId }
                                        onClosePanelFn: root.removeTopLeftPanel
                                        onMovePanelFn: root.moveTopLeftPanelByIndex
                                        onFloatPanelFn: root.floatPanel
                                        onAddPanelFn: root.addTopLeftPanel
                                    emptyText: qsTr("Top-left panel (add when needed)")
                                    }
                                Loader {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    active: root.topLeftCurrentId >= 0
                                        sourceComponent: root.panelSourceComponent(root.topLeftCurrentId)
                                    }
                                }
                            }

                            Item {
                                SplitView.fillHeight: true
                                SplitView.minimumHeight: 160
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    DockTabStack {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: tok.tabH + 2
                                        panelsModel: leftActivePanels
                                        currentPanelId: root.leftCurrentId
                                        panelMenuItems: root.panelMenuItems
                                        isPanelActiveFn: root.isPanelActive
                                        onSelectPanelFn: function(panelId) { root.leftCurrentId = panelId }
                                        onClosePanelFn: root.removePanel
                                        onMovePanelFn: root.movePanelByIndex
                                        onFloatPanelFn: root.floatPanel
                                        onAddPanelFn: root.addPanel
                                    }

                                    // ── Panel content ──────────────────────────────
                                    Item {
                                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true

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
                                                if (root.leftCurrentId > 28) Qt.callLater(root._syncPlaceholderMeta)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── CENTER: PREVIEW + TIMELINE ────────────────────────────
                SplitView {
                    id: centerSplit
                    orientation: Qt.Vertical
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 480

                    handle: Item {
                        implicitHeight: 1
                        Rectangle {
                            anchors.centerIn: parent; width: parent.width; height: 1
                            color: SplitHandle.pressed ? tok.borderFocus
                                 : SplitHandle.hovered ? tok.borderStrong : tok.borderNormal
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                    }

                    SplitView {
                        id: pvSlot
                        orientation: Qt.Horizontal
                        SplitView.preferredHeight: Math.max(260, centerSplit.height * root.previewRatio)
                        SplitView.minimumHeight: 200
                        SplitView.maximumHeight: Math.max(340, centerSplit.height * 0.82)

                        Item {
                            SplitView.minimumWidth: 220
                            SplitView.preferredWidth: root.centerTopLeftW
                            SplitView.maximumWidth: 680
                            onWidthChanged: if (width > 20) root.centerTopLeftW = Math.max(220, Math.min(680, width))

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                DockTabStack {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: tok.tabH + 2
                                    panelsModel: centerTopActivePanels
                                    currentPanelId: root.centerTopCurrentId
                                    panelMenuItems: root.panelMenuItems
                                    isPanelActiveFn: function(pid) { return root._isPanelActiveIn(centerTopActivePanels, pid) }
                                    onSelectPanelFn: function(panelId) { root.centerTopCurrentId = panelId }
                                    onClosePanelFn: root.removeCenterTopPanel
                                    onMovePanelFn: root.moveCenterTopPanelByIndex
                                    onFloatPanelFn: root.floatPanel
                                    onAddPanelFn: root.addCenterTopPanel
                                    emptyText: qsTr("Outline panel (add when needed)")
                                }
                                Loader {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    active: root.centerTopCurrentId >= 0
                                    sourceComponent: root.panelSourceComponent(root.centerTopCurrentId)
                                }
                            }
                        }

                        Item {
                            SplitView.fillWidth: true
                            SplitView.minimumWidth: 280
                            Rectangle { anchors.fill: parent; color: tok.deepest }
                            PreviewPanel { anchors.fill: parent }
                        }
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

                // ── MID INSPECTOR ─────────────────────────────────────────
                Item {
                    id: midPane
                    SplitView.minimumWidth:  root.showMidInspector ? 180 : 0
                    SplitView.preferredWidth: root.showMidInspector ? root.midInspectorW : 0
                    SplitView.maximumWidth:  root.showMidInspector ? 380 : 0
                    visible: root.showMidInspector; clip: true
                    onWidthChanged: {
                        if (root.showMidInspector && width > 10)
                            root.midInspectorW = Math.min(360, Math.max(180, width))
                    }

                    PanelFrame {
                        anchors.fill: parent
                        title: qsTr("INSPECTOR")
                        body: compInspector
                    }
                }

                // ── RIGHT: AI PANEL ───────────────────────────────────────
                Item {
                    id: rightPane
                    SplitView.minimumWidth:  !root.showRightColumn ? 0 : (root.rightExpanded ? 320 : 36)
                    SplitView.preferredWidth: !root.showRightColumn ? 0 : (root.rightExpanded ? Math.max(360, root.rightDockW) : 36)
                    SplitView.maximumWidth:  !root.showRightColumn ? 0 : (root.rightExpanded ? 680 : 38)
                    clip: true
                    onWidthChanged: {
                        if (root.showRightColumn && root.rightExpanded && width > 50)
                            root.rightDockW = Math.min(680, Math.max(320, width))
                    }

                    Rectangle {
                        anchors.fill: parent
                        // Very slightly warmer than tok.deep — feels distinct without any blue tint
                        color: root.showRightColumn && root.rightExpanded ? "#131210" : tok.deep
                        border.color: root.showRightColumn ? tok.borderNormal : "transparent"
                        border.width: 1

                        // ── Collapsed rail ─────────────────────────────────
                        Item {
                            anchors.fill: parent
                            visible: root.showRightColumn && !root.rightExpanded

                            Rectangle { anchors.fill: parent; color: tok.deep }
                            Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: tok.borderNormal }

                            ColumnLayout {
                                anchors.fill: parent; anchors.topMargin: 10; spacing: 10

                                Item {
                                    Layout.alignment: Qt.AlignHCenter; width: 24; height: 24
                                    HoverHandler { id: expandHover }
                                    Rectangle {
                                        anchors.fill: parent; radius: tok.radiusSM
                                        color: expandHover.hovered ? Qt.rgba(1,1,1,0.06) : "transparent"
                                    }
                                    Text {
                                        anchors.centerIn: parent; text: "›"
                                        font.pixelSize: 14; font.family: tok.fontFamily; color: tok.textSec
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: root.rightExpanded = true
                                    }
                                }

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter; width: 6; height: 6; radius: 3
                                    color: mainWindow && mainWindow.aiBusy ? tok.statusBusy : tok.statusIdle
                                }
                            }
                        }

                        // ── Expanded AI panel ──────────────────────────────
                        ColumnLayout {
                            anchors.fill: parent; spacing: 0
                            visible: root.showRightColumn && root.rightExpanded

                            // Header
                            Rectangle {
                                Layout.fillWidth: true; height: 38
                                color: "#141412"

                                Rectangle {
                                    anchors.bottom: parent.bottom; width: parent.width; height: 1
                                    color: tok.borderFaint
                                }

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 8; spacing: 8

                                    Rectangle {
                                        width: 6; height: 6; radius: 3
                                        color: mainWindow && mainWindow.aiBusy ? tok.statusBusy : tok.statusIdle
                                        border.color: Qt.rgba(1,1,1,0.08); border.width: 1
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: qsTr("AI ASSISTANT"); color: tok.textDisabled
                                        font.pixelSize: tok.fontSizeXS; font.family: tok.fontFamily
                                        font.weight: Font.Medium; font.letterSpacing: 1.1
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Model badge
                                    Rectangle {
                                        height: 18; width: badgeText.implicitWidth + 14; radius: 9
                                        color: Qt.rgba(1,1,1,0.06); border.color: tok.borderSubtle; border.width: 1
                                        Layout.alignment: Qt.AlignVCenter
                                        Text {
                                            id: badgeText; anchors.centerIn: parent; text: qsTr("Assistant")
                                            font.pixelSize: tok.fontSizeXS; font.family: tok.fontFamily; color: tok.textMuted
                                        }
                                    }

                                    // Collapse
                                    Item {
                                        width: 24; height: 24; Layout.alignment: Qt.AlignVCenter
                                        HoverHandler { id: collapseHover }
                                        Rectangle {
                                            anchors.fill: parent; radius: tok.radiusSM
                                            color: collapseHover.hovered ? Qt.rgba(1,1,1,0.06) : "transparent"
                                        }
                                        Text {
                                            anchors.centerIn: parent; text: "‹"
                                            font.pixelSize: 14; font.family: tok.fontFamily; color: tok.textMuted
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: root.rightExpanded = false
                                        }
                                    }
                                }
                            }

                            AIPromptPanel {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                onCloseRequested: root.rightExpanded = false
                            }
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FLOATING PANEL WINDOWS
    // ═══════════════════════════════════════════════════════════════════════
    Repeater {
        model: floatingPanels
        delegate: Window {
            required property int    index
            required property int    panelId
            required property string panelName
            required property int    posX
            required property int    posY
            required property int    widthPx
            required property int    heightPx

            title: panelName; visible: true
            minimumWidth: 280; minimumHeight: 220
            width: widthPx; height: heightPx
            x: posX; y: posY
            color: tok.surfaceLow

            onXChanged:      if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "posX",     x)
            onYChanged:      if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "posY",     y)
            onWidthChanged:  if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "widthPx",  width)
            onHeightChanged: if (index >= 0 && index < floatingPanels.count) floatingPanels.setProperty(index, "heightPx", height)

            onClosing: function(closeEvent) { closeEvent.accepted = false; root.redockFloating(index) }

            PanelFrame {
                anchors.fill: parent
                title: panelName
                showDockButton: true
                onDockFn: function() { root.redockFloating(index) }
                body: root.panelSourceComponent(panelId)
            }
        }
    }
}
