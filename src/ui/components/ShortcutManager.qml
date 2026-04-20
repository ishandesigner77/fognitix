import QtQuick
import QtQuick.Controls

// Central keyboard shortcut router. Attach once at the root of the main window.
// Every shortcut below is wired to an existing backend operation on mainWindow / appState.
Item {
    id: root
    anchors.fill: parent
    focus: true

    signal openProjectRequested()
    signal saveProjectRequested()
    signal saveProjectAsRequested()
    signal newProjectRequested()
    signal importMediaRequested()
    signal exportMediaRequested()
    signal toggleFullscreenRequested()
    signal openPanelRequested(string name)
    signal openSettingsRequested()
    signal openShortcutsRequested()
    signal focusAIRequested()
    signal focusQuickCommandRequested()

    // ── Playback ─────────────────────────────────────────────────────────
    Shortcut { sequence: "Space";        onActivated: if (mainWindow) mainWindow.togglePlayback() }
    Shortcut { sequence: "K";            onActivated: if (mainWindow) mainWindow.pause() }
    Shortcut { sequence: "L";            onActivated: if (mainWindow) mainWindow.nudgePlaybackRate(+1) }
    Shortcut { sequence: "J";            onActivated: if (mainWindow) mainWindow.nudgePlaybackRate(-1) }
    Shortcut { sequence: "Left";         onActivated: if (mainWindow) mainWindow.stepFrame(-1) }
    Shortcut { sequence: "Right";        onActivated: if (mainWindow) mainWindow.stepFrame(+1) }
    Shortcut { sequence: "Shift+Left";   onActivated: if (mainWindow) mainWindow.stepFrame(-10) }
    Shortcut { sequence: "Shift+Right";  onActivated: if (mainWindow) mainWindow.stepFrame(+10) }
    Shortcut { sequence: "Home";         onActivated: if (mainWindow) mainWindow.gotoStart() }
    Shortcut { sequence: "End";          onActivated: if (mainWindow) mainWindow.gotoEnd() }
    Shortcut { sequence: "I";            onActivated: if (mainWindow) mainWindow.setInPointAtPlayhead() }
    Shortcut { sequence: "O";            onActivated: if (mainWindow) mainWindow.setOutPointAtPlayhead() }
    Shortcut { sequence: "Shift+I";      onActivated: if (mainWindow) mainWindow.gotoInPoint() }
    Shortcut { sequence: "Shift+O";      onActivated: if (mainWindow) mainWindow.gotoOutPoint() }

    // ── Editing ──────────────────────────────────────────────────────────
    Shortcut { sequence: StandardKey.Undo;      onActivated: if (mainWindow) mainWindow.undo() }
    Shortcut { sequence: StandardKey.Redo;      onActivated: if (mainWindow) mainWindow.redo() }
    Shortcut { sequence: StandardKey.Cut;       onActivated: if (mainWindow) mainWindow.cutSelection() }
    Shortcut { sequence: StandardKey.Copy;      onActivated: if (mainWindow) mainWindow.copySelection() }
    Shortcut { sequence: StandardKey.Paste;     onActivated: if (mainWindow) mainWindow.paste() }
    Shortcut { sequence: StandardKey.Delete;    onActivated: if (mainWindow) mainWindow.deleteSelection() }
    Shortcut { sequence: "Shift+Del";           onActivated: if (mainWindow) mainWindow.rippleDelete() }
    Shortcut { sequence: "Ctrl+D";              onActivated: if (mainWindow) mainWindow.duplicateSelection() }
    Shortcut { sequence: "Ctrl+K";              onActivated: if (mainWindow) mainWindow.splitAtPlayhead() }
    Shortcut { sequence: StandardKey.SelectAll; onActivated: if (mainWindow) mainWindow.selectAll() }

    // ── Markers ──────────────────────────────────────────────────────────
    Shortcut { sequence: "M";            onActivated: if (mainWindow) mainWindow.addMarkerAtPlayhead() }
    Shortcut { sequence: "Shift+M";      onActivated: if (mainWindow) mainWindow.gotoNextMarker() }
    Shortcut { sequence: "Ctrl+Shift+M"; onActivated: if (mainWindow) mainWindow.gotoPrevMarker() }

    // ── Edit points nav ──────────────────────────────────────────────────
    Shortcut { sequence: "Up";           onActivated: if (mainWindow) mainWindow.gotoPrevEdit() }
    Shortcut { sequence: "Down";         onActivated: if (mainWindow) mainWindow.gotoNextEdit() }

    // ── Tools ────────────────────────────────────────────────────────────
    Shortcut { sequence: "V"; onActivated: if (mainWindow) mainWindow.setUiToolName("Selection") }
    Shortcut { sequence: "C"; onActivated: if (mainWindow) mainWindow.setUiToolName("Razor") }
    Shortcut { sequence: "B"; onActivated: if (mainWindow) mainWindow.setUiToolName("Ripple") }
    Shortcut { sequence: "N"; onActivated: if (mainWindow) mainWindow.setUiToolName("Rolling") }
    Shortcut { sequence: "Y"; onActivated: if (mainWindow) mainWindow.setUiToolName("Slip") }
    Shortcut { sequence: "U"; onActivated: if (mainWindow) mainWindow.setUiToolName("Slide") }
    Shortcut { sequence: "H"; onActivated: if (mainWindow) mainWindow.setUiToolName("Hand") }
    Shortcut { sequence: "Z"; onActivated: if (mainWindow) mainWindow.setUiToolName("Zoom") }

    // ── File ─────────────────────────────────────────────────────────────
    Shortcut { sequence: StandardKey.New;     onActivated: root.newProjectRequested() }
    Shortcut { sequence: StandardKey.Open;    onActivated: root.openProjectRequested() }
    Shortcut { sequence: StandardKey.Save;    onActivated: root.saveProjectRequested() }
    Shortcut { sequence: StandardKey.SaveAs;  onActivated: root.saveProjectAsRequested() }
    Shortcut { sequence: "Ctrl+I";            onActivated: root.importMediaRequested() }
    Shortcut { sequence: "Ctrl+Alt+M";        onActivated: root.exportMediaRequested() }

    // ── Tracks ───────────────────────────────────────────────────────────
    Shortcut { sequence: "Ctrl+Y";       onActivated: if (mainWindow) mainWindow.addVideoTrack("") }
    Shortcut { sequence: "Ctrl+U";       onActivated: if (mainWindow) mainWindow.addAudioTrack("") }

    // ── Panels ───────────────────────────────────────────────────────────
    Shortcut { sequence: "Ctrl+1"; onActivated: root.openPanelRequested("media") }
    Shortcut { sequence: "Ctrl+2"; onActivated: root.openPanelRequested("preview") }
    Shortcut { sequence: "Ctrl+3"; onActivated: root.openPanelRequested("timeline") }
    Shortcut { sequence: "Ctrl+4"; onActivated: root.openPanelRequested("effects") }
    Shortcut { sequence: "Ctrl+5"; onActivated: root.openPanelRequested("color") }
    Shortcut { sequence: "Ctrl+6"; onActivated: root.openPanelRequested("audio") }
    Shortcut { sequence: "Ctrl+7"; onActivated: root.openPanelRequested("ai") }
    Shortcut { sequence: "Ctrl+8"; onActivated: root.openPanelRequested("properties") }
    Shortcut { sequence: "Ctrl+9"; onActivated: root.openPanelRequested("scopes") }
    Shortcut { sequence: "Ctrl+0"; onActivated: root.openPanelRequested("keyframes") }
    Shortcut { sequence: "Ctrl+Shift+F"; onActivated: root.toggleFullscreenRequested() }

    // ── AI ───────────────────────────────────────────────────────────────
    Shortcut { sequence: "Ctrl+Shift+A";     onActivated: root.focusAIRequested() }
    Shortcut { sequence: "Ctrl+Shift+Space"; onActivated: root.focusQuickCommandRequested() }
    Shortcut { sequence: "Alt+A"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Auto-edit the selected clips") }
    Shortcut { sequence: "Alt+C"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Auto-color grade the selected clips") }
    Shortcut { sequence: "Alt+S"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Remove silences from the timeline") }
    Shortcut { sequence: "Alt+B"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Beat-sync cuts to the music") }
    Shortcut { sequence: "Alt+T"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Generate captions for the timeline") }
    Shortcut { sequence: "Alt+R"; onActivated: if (mainWindow) mainWindow.submitAiPrompt("Analyze footage and suggest edits") }

    // ── Settings / shortcuts dialog ──────────────────────────────────────
    Shortcut { sequence: "F12";          onActivated: root.openSettingsRequested() }
    Shortcut { sequence: "Ctrl+Alt+K";   onActivated: root.openShortcutsRequested() }
}
