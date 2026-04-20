import QtQuick

// Fognitix — Cursor-inspired premium palette
// ──────────────────────────────────────────────────────────────────────────
// Neutral near-black surfaces layered by a few points of lightness.
// Hairline borders. One warm champagne accent for focus/selection only.
// No blue, no purple, no neon. Subtle value shifts, not color shifts.
// Reference: Cursor — chat #181818, editor #141414, chat input #1f1f1f.
QtObject {

    // ─── Base surfaces — Cursor-style neutral layering ───────────────────────
    readonly property color appBg:          "#141414"   // outer window / editor body
    readonly property color panelBg:        "#181818"   // standard panel body
    readonly property color panelAlt:       "#161616"   // alt panel body
    readonly property color surfaceRaised:  "#1c1c1c"   // header strip, toolbar
    readonly property color surfaceHigh:    "#202020"   // buttons, cards, chips
    readonly property color surfacePeak:    "#262626"   // hover / pressed

    // ─── Borders — hairline, just enough to separate ─────────────────────────
    readonly property color borderHard:     "#000000"
    readonly property color borderMid:      "#0f0f0f"
    readonly property color borderSoft:     "#242424"
    readonly property color borderFocusRing:"#d4c9b0"

    // ─── Text hierarchy ──────────────────────────────────────────────────────
    readonly property color textPrimary:    "#ededed"
    readonly property color textSecondary:  "#9a9a9a"
    readonly property color textDisabled:   "#4d4d4d"
    readonly property color textMuted:      "#6b6b6b"
    readonly property color timecodeBright: "#f0f0f0"

    // ─── Single functional accent — warm champagne ───────────────────────────
    readonly property color accent:         "#d4c9b0"
    readonly property color accentHover:    "#e2d8c0"
    readonly property color accentActive:   "#bdb09a"
    readonly property color accentMuted:    "#24211a"
    readonly property color accentText:     "#d4c9b0"

    // ─── Status — desaturated ────────────────────────────────────────────────
    readonly property color success:        "#7a8470"
    readonly property color warning:        "#a8956a"
    readonly property color danger:         "#9a6a5e"
    readonly property color info:           "#7a7f88"

    // ─── Playhead / in-out ───────────────────────────────────────────────────
    readonly property color playhead:       "#ededed"
    readonly property color playheadLine:   "#ededed80"
    readonly property color inOutPoint:     "#9a9a9a"

    // ─── Timeline surfaces ───────────────────────────────────────────────────
    readonly property color timelineBg:     "#141414"
    readonly property color timelineHeader: "#181818"
    readonly property color timelineRuler:  "#141414"
    readonly property color timelineBeat:   "#1a1a1a"
    readonly property color trackRowEven:   "#181818"
    readonly property color trackRowOdd:    "#161616"

    // ─── Clip colors — value-based, not hue-based ────────────────────────────
    readonly property color clipVideo:      "#3a3a3a"
    readonly property color clipVideoBg:    "#2a2a2a"
    readonly property color clipAudio:      "#3a3835"
    readonly property color clipAudioBg:    "#2a2825"
    readonly property color clipText:       "#343434"
    readonly property color clipTextBg:     "#262626"
    readonly property color clipAdj:        "#403a30"
    readonly property color clipAdjBg:      "#2e2a22"
    readonly property color waveformColor:  "#8a8580"

    // ─── Track label strip — muted-saturated, visible (4px left strip) ──────
    readonly property color trackVideo:     "#5a7aa0"   // dusty blue
    readonly property color trackAudio:     "#6ea078"   // muted sage
    readonly property color trackText:      "#9278a8"   // muted violet
    readonly property color trackAdj:       "#b08a55"   // warm amber
    readonly property color trackNull:      "#3a3a3a"

    // ─── Keyframes ───────────────────────────────────────────────────────────
    readonly property color keyframe:       "#9a9a9a"
    readonly property color keyframeHover:  "#c8c8c8"
    readonly property color keyframeSelect: "#d4c9b0"

    // ─── Scrollbar ───────────────────────────────────────────────────────────
    readonly property color scrollbar:      "#2a2a2a"
    readonly property color scrollbarHover: "#3a3a3a"

    // ─── AI panel ────────────────────────────────────────────────────────────
    readonly property color aiBubble:       "#1c1c1c"
    readonly property color aiAccent:       "#d4c9b0"
    readonly property color aiMuted:        "#181818"
    readonly property color aiPanelDeep:    "#0e0e10"   // full-height AI column base
    readonly property color chromePopup:    "#121214"   // menus / combo popups
    readonly property color chromePopupHover: "#1e1e22"
    readonly property color chromePopupBorder: "#2c2c32"
    readonly property color chromeEdge:     "#3d3a34"   // subtle gold-grey edge (pro tool feel)

    // ─── Aliases — DO NOT REMOVE ─────────────────────────────────────────────
    readonly property color windowRoot:         appBg
    readonly property color menuBarBackground:  "#141414"
    readonly property color statusBarBackground: "#0a0a0a"   // darkest chrome — anchors the bottom
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
    readonly property color timelineMinimapBg:  "#101010"
    readonly property color timelineRulerFg:    textDisabled
    readonly property color snapLine:           Qt.rgba(1, 1, 1, 0.12)

    readonly property color clipVideoTop:       clipVideo
    readonly property color clipVideoBot:       clipVideoBg
    readonly property color clipAudioFill:      clipAudioBg
    readonly property color waveformTone:       waveformColor

    readonly property color viewerBlack:        "#000000"
    readonly property color previewSurround:    "#000000"
    readonly property color scopeBackground:    "#101010"

    readonly property color splitter:           borderHard
    readonly property color splitterHover:      Qt.rgba(1, 1, 1, 0.06)
    readonly property color splitterActive:     accent

    readonly property color edgeHighlight:      borderSoft
    readonly property color selectionOverlay:   Qt.rgba(212, 201, 176, 0.06)

    readonly property color supremeTextPrimary:   textPrimary
    readonly property color supremeTextSecondary: textSecondary
    readonly property color supremeTextTertiary:  textMuted
    readonly property color supremeTextDisabled:  textDisabled
    readonly property color supremeTimecode:      textPrimary
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
    readonly property color supremeBgMenu:        "#141414"
    readonly property color supremeBgTimeline:    timelineBg
    readonly property color supremeBgPreview:     "#000000"
    readonly property color supremeBgPanelHdr:    surfaceRaised
    readonly property color supremeDanger:        danger
    readonly property color supremeSuccess:       success
    readonly property color supremeWarning:       warning
    readonly property color supremeInfo:          info
}
