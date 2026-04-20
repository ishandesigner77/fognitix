import QtQuick

QtObject {
    // Neutral light — grey chrome, muted clip fills (no blue accent)

    readonly property color bgMain:           "#eef0f2"
    readonly property color panel:            "#ffffff"
    readonly property color panelElevated:    "#e4e6ea"
    readonly property color panelHeaderBg:  "#e8eaee"
    readonly property color panelSurface2:  "#dce0e6"
    readonly property color borderHairline: "#d0d4da"
    readonly property color divider:        "#c4c8ce"

    readonly property color primary:        "#5a5a62"
    readonly property color audio:          "#6a6e74"
    readonly property color warning:        "#7a7672"
    readonly property color danger:         "#726868"
    readonly property color selectionOverlay: Qt.rgba(0, 0, 0, 0.06)

    readonly property color textMain:         "#1a1a1e"
    readonly property color textSecondary:  "#5a5c62"
    readonly property color textMuted:      "#7a7c82"
    readonly property color textTertiary:  "#7a7c82"
    readonly property color textAccent:    textSecondary
    readonly property color textDisabled:   "#a0a2a8"
    readonly property color timecodeBright: "#2a2a30"

    readonly property color timelineChrome:   "#e0e2e6"
    readonly property color timelineRulerFg:  "#6a6c72"
    readonly property color snapLine:       Qt.rgba(0, 0, 0, 0.14)
    readonly property color clipVideoTop:   "#c8ccd4"
    readonly property color clipVideoBot:   "#d4d8de"
    readonly property color clipAudioFill:  "#c8d0cc"
    readonly property color waveformTone:   "#5a6864"
    readonly property color viewerBlack:    "#0a0a0c"

    readonly property color windowRoot:         bgMain
    readonly property color menuBarBackground:  panel
    readonly property color statusBarBackground: "#e2e4e8"
    readonly property color menuBarHighlight:   panelElevated
    readonly property color primaryBackground:  bgMain
    readonly property color panelBackground:    panel
    readonly property color secondaryPanel:     panelElevated
    readonly property color tertiaryPanel:      panelElevated
    readonly property color elevated:           panelElevated
    readonly property color previewSurround:   viewerBlack

    readonly property color borderColor:        borderHairline
    readonly property color borderSubtle:       divider
    readonly property color borderMedium:     "#b4b8be"
    readonly property color borderFocus:      "#5a5a62"

    readonly property color textPrimary:    textMain
    readonly property color chromeFrame:    textMain

    readonly property color accent:         primary
    readonly property color accentHover:    "#4a4a52"
    readonly property color accentActive:   "#3a3a42"
    readonly property color accentMuted:    "#e0e2e6"

    readonly property color aiAccent:       textSecondary
    readonly property color aiMuted:          panelElevated
    readonly property color aiBubble:       panelElevated
    readonly property color aiPanelDeep:    "#f0f1f4"
    readonly property color chromePopup:    "#ffffff"
    readonly property color chromePopupHover: "#e8eaee"
    readonly property color chromePopupBorder: borderHairline
    readonly property color chromeEdge:     "#c8c4bc"

    readonly property color success:    audio
    readonly property color info:       primary

    readonly property color timelineBackground: timelineChrome
    readonly property color timelineHeader:     panelHeaderBg
    readonly property color timelineRuler:      timelineChrome
    readonly property color timelineMinimapBg: "#d0d4da"
    readonly property color timelineBeat:       panelElevated
    readonly property color playhead:         "#4a4a52"
    readonly property color playheadHead:     playhead
    readonly property color playheadLine:     "#4a4a5288"
    readonly property color inOutPoint:       textSecondary

    readonly property color clipVideo:      clipVideoTop
    readonly property color clipVideoBg:    clipVideoBot
    readonly property color clipAudio:      waveformTone
    readonly property color clipAudioBg:    clipAudioFill
    readonly property color clipText:       "#b8b4c4"
    readonly property color clipTextBg:     "#e4e2ea"
    readonly property color clipAdj:        textSecondary
    readonly property color clipAdjBg:      "#eae6e0"

    readonly property color keyframe:       "#6a6c72"
    readonly property color keyframeHover:  "#5a5c62"
    readonly property color keyframeSelect: "#4a4c52"

    readonly property color trackVideo:     "#c8ccd4"
    readonly property color trackAudio:     "#c8d4d0"
    readonly property color trackText:      "#d4d0dc"
    readonly property color trackAdj:       "#dcd8d4"
    readonly property color trackNull:      panelElevated

    readonly property color scrollbar:      "#c4c8ce"
    readonly property color scrollbarHover: "#a8acb2"

    readonly property color edgeHighlight:  divider
    readonly property color scopeBackground: timelineChrome

    readonly property color splitter:      borderHairline
    readonly property color splitterHover: Qt.rgba(0, 0, 0, 0.1)
    readonly property color splitterActive: "#5a5a62"
}
