import QtQuick

// Fognitix — premium neutral palette (no blue, no purple)
// Warm graphite base with champagne accent.
QtObject {

    // ─── Base surfaces — neutral ladder ──────────────────────────────────────
    readonly property color appBg:          "#141414"
    readonly property color panelBg:        "#181818"
    readonly property color panelAlt:       "#1c1c1c"
    readonly property color surfaceRaised:  "#1f1f1f"
    readonly property color surfaceHigh:    "#242424"
    readonly property color surfacePeak:    "#2c2c2c"

    // ─── Borders — hairline separation ────────────────────────────────────────
    readonly property color borderHard:     "#000000"
    readonly property color borderMid:      "#101010"
    readonly property color borderSoft:     "#1a1a1a"
    readonly property color borderFocusRing:"#d4c9b0"

    // ─── Text hierarchy ───────────────────────────────────────────────────────
    readonly property color textPrimary:    "#ececec"
    readonly property color textSecondary:  "#a8a8a8"
    readonly property color textDisabled:   "#5a5a5a"
    readonly property color textMuted:      "#7a7a7a"
    readonly property color timecodeBright: "#e8e2d2"

    // ─── Functional accent — warm champagne ───────────────────────────────────
    readonly property color accent:         "#d4c9b0"
    readonly property color accentHover:    "#e2d9c2"
    readonly property color accentActive:   "#b8ad94"
    readonly property color accentMuted:    "#2a2620"
    readonly property color accentText:     "#e8dfc8"

    // ─── Status — desaturated ─────────────────────────────────────────────────
    readonly property color success:        "#7a8f6d"
    readonly property color warning:        "#b89a5a"
    readonly property color danger:         "#c45a52"
    readonly property color info:           "#8a7f6a"

    // ─── Playhead / in-out — warm red CTI ────────────────────────────────────
    readonly property color playhead:       "#c86050"
    readonly property color playheadLine:   "#c8605099"
    readonly property color inOutPoint:     "#9a9a9a"

    // ─── Timeline surfaces ───────────────────────────────────────────────────
    readonly property color timelineBg:     "#121212"
    readonly property color timelineHeader: "#171717"
    readonly property color timelineRuler:  "#141414"
    readonly property color timelineBeat:   "#1c1c1c"
    readonly property color trackRowEven:   "#1e1e1e"
    readonly property color trackRowOdd:    "#1a1a1a"

    // ─── Clip colors — readable on dark tracks ────────────────────────────────
    readonly property color clipVideo:      "#8b806c"
    readonly property color clipVideoBg:    "#302a22"
    readonly property color clipAudio:      "#6e9a78"
    readonly property color clipAudioBg:    "#28382c"
    readonly property color clipText:       "#9d8570"
    readonly property color clipTextBg:     "#332a20"
    readonly property color clipAdj:        "#b08a55"
    readonly property color clipAdjBg:      "#3a3020"
    readonly property color waveformColor:  "#8a9a7d"

    // ─── Track label strip (left gutter) ─────────────────────────────────────
    readonly property color trackVideo:     "#8b806c"
    readonly property color trackAudio:     "#6e9a78"
    readonly property color trackText:      "#9d8570"
    readonly property color trackAdj:       "#b08a55"
    readonly property color trackNull:      "#3a3a3a"

    // ─── Keyframes ─────────────────────────────────────────────────────────────
    readonly property color keyframe:       "#8a8a8a"
    readonly property color keyframeHover:  "#c8c8c8"
    readonly property color keyframeSelect: "#d4c9b0"

    // ─── Scrollbar ─────────────────────────────────────────────────────────────
    readonly property color scrollbar:      "#242424"
    readonly property color scrollbarHover: "#2f2f2f"

    // ─── AI / chrome popups ───────────────────────────────────────────────────
    readonly property color aiBubble:         "#1c1c1c"
    readonly property color aiAccent:         "#d4c9b0"
    readonly property color aiMuted:          "#1f1f1f"
    readonly property color aiPanelDeep:      "#141414"
    readonly property color chromePopup:      "#1f1f1f"
    readonly property color chromePopupHover: "#2a2a2a"
    readonly property color chromePopupBorder:"#141414"
    readonly property color chromeEdge:       "#2a2620"

    // ─── Aliases — DO NOT REMOVE ─────────────────────────────────────────────
    readonly property color windowRoot:         appBg
    readonly property color menuBarBackground:  "#181818"
    readonly property color statusBarBackground:"#141414"
    readonly property color primaryBackground:  appBg
    readonly property color panelBackground:    panelBg
    readonly property color secondaryPanel:     panelAlt
    readonly property color tertiaryPanel:      surfaceRaised
    readonly property color elevated:           surfaceHigh
    readonly property color panelElevated:      surfaceRaised

    readonly property color borderColor:        borderSoft
    readonly property color borderSubtle:       borderMid
    readonly property color borderHairline:     borderHard
    readonly property color borderFocus:        borderFocusRing

    readonly property color bgMain:             appBg
    readonly property color panel:              panelBg
    readonly property color divider:            borderMid

    readonly property color textMain:           textPrimary
    readonly property color textTertiary:       textDisabled
    readonly property color textAccent:         accentText

    readonly property color timelineChrome:     timelineBg
    readonly property color timelineBackground: timelineBg
    readonly property color timelineMinimapBg:  "#141414"
    readonly property color timelineRulerFg:    textMuted
    readonly property color snapLine:           Qt.rgba(0.83, 0.79, 0.69, 0.22)

    readonly property color clipVideoTop:       clipVideo
    readonly property color clipVideoBot:       clipVideoBg
    readonly property color clipAudioFill:      clipAudioBg
    readonly property color waveformTone:       waveformColor

    readonly property color viewerBlack:        "#000000"
    readonly property color previewSurround:    "#000000"
    readonly property color scopeBackground:    "#141414"

    readonly property color splitter:           borderHard
    readonly property color splitterHover:      Qt.rgba(1, 1, 1, 0.05)
    readonly property color splitterActive:     accent

    readonly property color edgeHighlight:      borderSoft
    readonly property color selectionOverlay:   Qt.rgba(0.83, 0.79, 0.69, 0.10)

    readonly property color supremeTextPrimary:   textPrimary
    readonly property color supremeTextSecondary: textSecondary
    readonly property color supremeTextTertiary:  textMuted
    readonly property color supremeTextDisabled:  textDisabled
    readonly property color supremeTimecode:      timecodeBright
    readonly property color supremeAccent:        accent
    readonly property color supremeAccentHover:   accentHover
    readonly property color supremeAccentActive:  accentActive
    readonly property color supremeAccentSubtle:  accentMuted
    readonly property color supremePlayhead:      playhead
    readonly property color supremePlayheadLine:  playheadLine
    readonly property color supremeBorderSubtle:  borderMid
    readonly property color supremeBorderDefault: borderSoft
    readonly property color supremeBorderMedium:  surfaceHigh
    readonly property color supremeBorderStrong:  surfacePeak
    readonly property color supremeBgApp:         appBg
    readonly property color supremeBgPanel:       panelBg
    readonly property color supremeBgSurface:     surfaceRaised
    readonly property color supremeBgSurface2:    panelAlt
    readonly property color supremeBgSurface3:    surfaceRaised
    readonly property color supremeBgMenu:        menuBarBackground
    readonly property color supremeBgTimeline:    timelineBg
    readonly property color supremeBgPreview:     "#000000"
    readonly property color supremeBgPanelHdr:    surfaceRaised
    readonly property color supremeDanger:        danger
    readonly property color supremeSuccess:       success
    readonly property color supremeWarning:       warning
    readonly property color supremeInfo:          info
}
