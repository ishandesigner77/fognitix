import QtQuick

// Fognitix — professional NLE / motion palette (Resolve / Premiere / AE-class)
// ──────────────────────────────────────────────────────────────────────────
// Five-tone neutral stack: #171717 #1a1a1a #1c1c1c #242424 #262626
// Hairline borders. One cool functional accent (timecode, CTI, focus) like industry tools.
QtObject {

    // ─── Base surfaces — strict neutral ladder ───────────────────────────────
    readonly property color appBg:          "#1c1c1c"   // workspace chrome
    readonly property color panelBg:        "#262626"   // primary panel fill
    readonly property color panelAlt:         "#242424"   // alternate / inset rows
    readonly property color surfaceRaised:  "#262626"   // panel headers, toolbars
    readonly property color surfaceHigh:    "#2c2c2c"   // buttons, chips, raised controls
    readonly property color surfacePeak:    "#343434"   // hover / pressed

    // ─── Borders — hairline separation ────────────────────────────────────────
    readonly property color borderHard:     "#000000"
    readonly property color borderMid:      "#141414"
    readonly property color borderSoft:     "#1a1a1a"
    readonly property color borderFocusRing:"#47a8ff"

    // ─── Text hierarchy ───────────────────────────────────────────────────────
    readonly property color textPrimary:    "#ececec"
    readonly property color textSecondary:  "#a8a8a8"
    readonly property color textDisabled:   "#5a5a5a"
    readonly property color textMuted:      "#7a7a7a"
    readonly property color timecodeBright: "#cfe8ff"

    // ─── Functional accent — cool blue (timecode / CTI / selection) ───────────
    readonly property color accent:         "#47a8ff"
    readonly property color accentHover:    "#6bb8ff"
    readonly property color accentActive:   "#2f8ae6"
    readonly property color accentMuted:    "#1a2e40"
    readonly property color accentText:     "#9fd4ff"

    // ─── Status — desaturated ─────────────────────────────────────────────────
    readonly property color success:        "#6d8f6d"
    readonly property color warning:        "#b89a5a"
    readonly property color danger:         "#c45a52"
    readonly property color info:           "#6a7f92"

    // ─── Playhead / in-out ───────────────────────────────────────────────────
    readonly property color playhead:       "#47a8ff"
    readonly property color playheadLine:   "#47a8ff99"
    readonly property color inOutPoint:     "#9a9a9a"

    // ─── Timeline surfaces ───────────────────────────────────────────────────
    readonly property color timelineBg:     "#171717"
    readonly property color timelineHeader: "#1a1a1a"
    readonly property color timelineRuler:  "#171717"
    readonly property color timelineBeat:   "#1f1f1f"
    readonly property color trackRowEven:   "#242424"
    readonly property color trackRowOdd:    "#1e1e1e"

    // ─── Clip colors — readable on dark tracks ────────────────────────────────
    readonly property color clipVideo:      "#4a6fa8"
    readonly property color clipVideoBg:    "#2a3550"
    readonly property color clipAudio:      "#4d8f6a"
    readonly property color clipAudioBg:    "#24362c"
    readonly property color clipText:       "#6a5a90"
    readonly property color clipTextBg:     "#2c2438"
    readonly property color clipAdj:        "#a8844a"
    readonly property color clipAdjBg:      "#3a3020"
    readonly property color waveformColor:  "#7d9a86"

    // ─── Track label strip (left gutter) ─────────────────────────────────────
    readonly property color trackVideo:     "#5a7aa0"
    readonly property color trackAudio:     "#5e9a72"
    readonly property color trackText:      "#8a78a8"
    readonly property color trackAdj:       "#b08a55"
    readonly property color trackNull:      "#3a3a3a"

    // ─── Keyframes ─────────────────────────────────────────────────────────────
    readonly property color keyframe:         "#8a8a8a"
    readonly property color keyframeHover:  "#c8c8c8"
    readonly property color keyframeSelect: "#47a8ff"

    // ─── Scrollbar ─────────────────────────────────────────────────────────────
    readonly property color scrollbar:        "#2a2a2a"
    readonly property color scrollbarHover: "#3a3a3a"

    // ─── AI / chrome popups ───────────────────────────────────────────────────
    readonly property color aiBubble:         "#1e1e1e"
    readonly property color aiAccent:         "#47a8ff"
    readonly property color aiMuted:          "#242424"
    readonly property color aiPanelDeep:      "#171717"
    readonly property color chromePopup:      "#262626"
    readonly property color chromePopupHover: "#303030"
    readonly property color chromePopupBorder:"#1a1a1a"
    readonly property color chromeEdge:       "#2a3d52"

    // ─── Aliases — DO NOT REMOVE ─────────────────────────────────────────────
    readonly property color windowRoot:         appBg
    readonly property color menuBarBackground:  "#262626"
    readonly property color statusBarBackground:"#171717"
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
    readonly property color timelineMinimapBg:  "#171717"
    readonly property color timelineRulerFg:    textMuted
    readonly property color snapLine:           Qt.rgba(0.28, 0.66, 1.0, 0.22)

    readonly property color clipVideoTop:       clipVideo
    readonly property color clipVideoBot:       clipVideoBg
    readonly property color clipAudioFill:      clipAudioBg
    readonly property color waveformTone:       waveformColor

    readonly property color viewerBlack:        "#000000"
    readonly property color previewSurround:    "#000000"
    readonly property color scopeBackground:    "#171717"

    readonly property color splitter:           borderHard
    readonly property color splitterHover:      Qt.rgba(1, 1, 1, 0.06)
    readonly property color splitterActive:     accent

    readonly property color edgeHighlight:      borderSoft
    readonly property color selectionOverlay:   Qt.rgba(0.28, 0.66, 1.0, 0.10)

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
    readonly property color supremeBorderStrong: surfacePeak
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
