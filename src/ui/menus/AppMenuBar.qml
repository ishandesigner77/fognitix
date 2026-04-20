import QtQuick
import QtQuick.Controls
import Fognitix

MenuBar {
    id: bar
    required property var menuHost

    implicitHeight: 28

    /* Qt Quick MenuBar shows QAction-style &mnemonics literally unless stripped */
    QtObject {
        id: _mn
        function strip(s) {
            if (!s || s.length === 0)
                return ""
            var t = String(s).replace(/&&/g, "\uE000")
            t = t.replace(/&([^&])/g, "$1")
            return t.replace(/\uE000/g, "&")
        }
    }

    background: Rectangle {
        color: theme.colors.menuBarBackground
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle }
    }

    Rectangle {
        id: topSearchWrap
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 240
        height: 22
        radius: 3
        color: theme.colors.chromePopup
        border.color: topSearchField.activeFocus ? theme.colors.accent : theme.colors.chromePopupBorder
        border.width: 1
        z: 100

        TextField {
            id: topSearchField
            anchors.fill: parent
            anchors.leftMargin: 7
            anchors.rightMargin: 7
            placeholderText: qsTr("Search")
            background: null
            font.pixelSize: 10
            color: theme.colors.textPrimary
            placeholderTextColor: theme.colors.textDisabled
            onAccepted: {
                if (mainWindow && text.length > 0 && typeof mainWindow.runCommandSearch === "function")
                    mainWindow.runCommandSearch(text)
                text = ""
            }
        }
    }

    delegate: MenuBarItem {
        id: mbi
        implicitHeight: 28
        contentItem: Text {
            text: _mn.strip(mbi.text)
            color: mbi.highlighted ? theme.colors.textPrimary : theme.colors.textSecondary
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
            leftPadding: 4; rightPadding: 4
        }
        background: Rectangle {
            color: mbi.highlighted ? theme.colors.accentMuted : "transparent"
            radius: 3
            border.color: mbi.highlighted ? theme.colors.accent : "transparent"
        }
    }

    Theme { id: theme }

    // ── FILE ─────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&File")
        Menu {
            title: qsTr("New")
            Action { text: qsTr("Project…");             shortcut: "Ctrl+N";        onTriggered: menuHost.prepareAndOpenNewProject() }
            Action { text: qsTr("Production…");          enabled: false }
            Action { text: qsTr("Team Project…");        enabled: false }
            Action { text: qsTr("Sequence…");            shortcut: "Ctrl+Shift+N";  enabled: false }
            Action { text: qsTr("Bin");                  enabled: false }
            Action { text: qsTr("Legacy Title…");        enabled: false }
            Action {
                text: qsTr("Composition…")
                onTriggered: menuHost.openCompositionSettingsDialog()
            }
        }
        Action { text: qsTr("Open Project…");            shortcut: "Ctrl+O";        onTriggered: menuHost.openProjectDialog() }
        Action { text: qsTr("Open Production…");         enabled: false }
        Action { text: qsTr("Open Team Project…");       enabled: false }
        Menu {
            title: qsTr("Open Recent")
            Action { text: mainWindow ? (mainWindow.lastRecentProjectPath() || qsTr("(none)")) : qsTr("(none)"); onTriggered: if (mainWindow) mainWindow.openLastRecentProject() }
            MenuSeparator {}
            Action { text: qsTr("Clear Recent"); enabled: false }
        }
        MenuSeparator {}
        Action { text: qsTr("Close");                    shortcut: "Ctrl+W";        enabled: false }
        Action { text: qsTr("Close Project");            shortcut: "Ctrl+Shift+W";  enabled: false }
        Action { text: qsTr("Close Production");         enabled: false }
        Action { text: qsTr("Close All Projects");       enabled: false }
        Action { text: qsTr("Close All Other Projects"); enabled: false }
        Action { text: qsTr("Refresh All Projects");     enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Save");                     shortcut: "Ctrl+S";        onTriggered: if (mainWindow) mainWindow.saveProject() }
        Action { text: qsTr("Save As…");                 shortcut: "Ctrl+Shift+S";  onTriggered: menuHost.openSaveProjectAsDialog() }
        Action { text: qsTr("Save a Copy…");             shortcut: "Ctrl+Alt+S";    onTriggered: menuHost.openSaveProjectAsDialog() }
        Action { text: qsTr("Save as Template…");        enabled: false }
        Action { text: qsTr("Increment and Save");       shortcut: "Ctrl+Alt+Shift+S"; enabled: false }
        Action { text: qsTr("Save All");                 enabled: false }
        Action { text: qsTr("Revert");                   enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Link Media…");              enabled: false }
        Action { text: qsTr("Make Offline…");            enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Import…");                  shortcut: "Ctrl+I";        onTriggered: menuHost.openImportDialog() }
        Action { text: qsTr("Import from Media Browser"); enabled: false }
        Action { text: qsTr("Import Recent File");       enabled: false }
        Menu {
            title: qsTr("Export")
            Action { text: qsTr("Export Media…");            shortcut: "Ctrl+Alt+M"; onTriggered: menuHost.openExportDialog() }
            Action { text: qsTr("Export Frame…");            enabled: false }
            Action { text: qsTr("Export EDL…");              enabled: false }
            Action { text: qsTr("Export XML (FCP)…");        enabled: false }
            Action { text: qsTr("Export AAF…");              enabled: false }
            Action { text: qsTr("Export as Motion Graphics Template…"); enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Add to Render Queue");      shortcut: "Ctrl+Shift+M"; enabled: false }
            Action { text: qsTr("Add to Render Queue…");          onTriggered: menuHost.openRenderQueuePanel() }
        }
        MenuSeparator {}
        Action { text: qsTr("Watch Folder…");            enabled: false }
        Action { text: qsTr("Scripts");                  enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Project Settings…");        enabled: false }
        Action { text: qsTr("Production Settings…");     enabled: false }
        Action { text: qsTr("Project Manager…");         enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Find…");                    shortcut: "Ctrl+F"; enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Exit");                     shortcut: "Alt+F4";        onTriggered: Qt.quit() }
    }

    // ── EDIT ─────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Edit")
        Action { text: qsTr("Undo");                     shortcut: StandardKey.Undo;   enabled: mainWindow && mainWindow.canUndo; onTriggered: if (mainWindow) mainWindow.undo() }
        Action { text: qsTr("Redo");                     shortcut: StandardKey.Redo;   enabled: mainWindow && mainWindow.canRedo; onTriggered: if (mainWindow) mainWindow.redo() }
        Menu { title: qsTr("History"); Action { text: qsTr("(view in History panel)"); enabled: false } }
        MenuSeparator {}
        Action { text: qsTr("Cut");                      shortcut: StandardKey.Cut;    onTriggered: if (mainWindow) mainWindow.cutSelection() }
        Action { text: qsTr("Copy");                     shortcut: StandardKey.Copy;   onTriggered: if (mainWindow) mainWindow.copySelection() }
        Action { text: qsTr("Copy with Property Links"); enabled: false }
        Action { text: qsTr("Copy with Relative Property Links"); enabled: false }
        Action { text: qsTr("Copy Expression Only");     enabled: false }
        Action { text: qsTr("Paste");                    shortcut: StandardKey.Paste;  onTriggered: if (mainWindow) mainWindow.paste() }
        Action { text: qsTr("Paste Insert");             shortcut: "Ctrl+Shift+V";     enabled: false }
        Action { text: qsTr("Paste Attributes…");        shortcut: "Ctrl+Alt+V";       enabled: false }
        Action { text: qsTr("Remove Attributes…");       enabled: false }
        Action { text: qsTr("Paste Reversed Keyframes"); enabled: false }
        Action { text: qsTr("Paste Text and Match Formatting"); enabled: false }
        Action { text: qsTr("Paste Mocha Mask");         enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Clear");                    shortcut: StandardKey.Delete; onTriggered: if (mainWindow) mainWindow.deleteSelection() }
        Action { text: qsTr("Ripple Delete");            shortcut: "Shift+Del";        onTriggered: if (mainWindow) mainWindow.rippleDelete() }
        Action { text: qsTr("Duplicate");                shortcut: "Ctrl+D";           onTriggered: if (mainWindow) mainWindow.duplicateSelection() }
        Action { text: qsTr("Split Layer");              shortcut: "Ctrl+Shift+D";     enabled: false }
        Action { text: qsTr("Lift Work Area");           enabled: false }
        Action { text: qsTr("Extract Work Area");        enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Select All");               shortcut: StandardKey.SelectAll; onTriggered: if (mainWindow) mainWindow.selectAll() }
        Action { text: qsTr("Select All Matching");      enabled: false }
        Action { text: qsTr("Deselect All");             shortcut: "Ctrl+Shift+A";     onTriggered: if (mainWindow) mainWindow.deselectAll() }
        MenuSeparator {}
        Action { text: qsTr("Find…");                    shortcut: "Ctrl+F";           enabled: false }
        Action { text: qsTr("Find Next");                shortcut: "Ctrl+G";           enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Label");                    enabled: false }
        Action { text: qsTr("Remove Unused");            enabled: false }
        Action { text: qsTr("Consolidate Duplicates");   enabled: false }
        Action { text: qsTr("Generate Source Clips for Media"); enabled: false }
        Action { text: qsTr("Reassociate Source Clips…"); enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Edit Original…");           enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Team Project");             enabled: false }
        MenuSeparator {}
        Menu {
            title: qsTr("Clip")
            Action { text: qsTr("Split at Playhead");        shortcut: "Ctrl+K";        onTriggered: if (mainWindow) mainWindow.splitAtPlayhead() }
            Action { text: qsTr("Link");                     shortcut: "Ctrl+L";        enabled: false }
            Action { text: qsTr("Group");                    shortcut: "Ctrl+G";        enabled: false }
            Action { text: qsTr("Ungroup");                  shortcut: "Ctrl+Shift+G";  enabled: false }
            Action { text: qsTr("Speed/Duration…");          shortcut: "Ctrl+R";        enabled: false }
        }
        Menu {
            title: qsTr("Sequence")
            Action { text: qsTr("Match Frame");              shortcut: "F";             onTriggered: if (mainWindow) mainWindow.seek(appState ? appState.playheadSeconds : 0) }
            Action { text: qsTr("Add Edit");                 shortcut: "Ctrl+K";        onTriggered: if (mainWindow) mainWindow.splitAtPlayhead() }
            Action { text: qsTr("Add Tracks…");              onTriggered: if (mainWindow) mainWindow.addVideoTrack("") }
            Action { text: qsTr("Go to Previous Edit");      shortcut: "Up";            onTriggered: if (mainWindow) mainWindow.gotoPrevEdit() }
            Action { text: qsTr("Go to Next Edit");          shortcut: "Down";          onTriggered: if (mainWindow) mainWindow.gotoNextEdit() }
        }
        Menu {
            title: qsTr("Markers")
            Action { text: qsTr("Mark In");                  shortcut: "I";             onTriggered: if (mainWindow) mainWindow.setInPointAtPlayhead() }
            Action { text: qsTr("Mark Out");                 shortcut: "O";             onTriggered: if (mainWindow) mainWindow.setOutPointAtPlayhead() }
            Action { text: qsTr("Go to In");                 shortcut: "Shift+I";       onTriggered: if (mainWindow) mainWindow.gotoInPoint() }
            Action { text: qsTr("Go to Out");                shortcut: "Shift+O";       onTriggered: if (mainWindow) mainWindow.gotoOutPoint() }
            Action { text: qsTr("Clear In");                 shortcut: "Ctrl+Shift+I";  onTriggered: if (appState) appState.clearInPoint() }
            Action { text: qsTr("Clear Out");                shortcut: "Ctrl+Shift+O";  onTriggered: if (appState) appState.clearOutPoint() }
            Action { text: qsTr("Clear In and Out");         shortcut: "Ctrl+Shift+X";  onTriggered: if (appState) appState.clearInOut() }
            Action { text: qsTr("Add Marker");               shortcut: "M";             onTriggered: if (mainWindow) mainWindow.addMarkerAtPlayhead() }
            Action { text: qsTr("Go to Next Marker");        shortcut: "Shift+M";       onTriggered: if (mainWindow) mainWindow.gotoNextMarker() }
            Action { text: qsTr("Go to Previous Marker");    shortcut: "Ctrl+Shift+M";  onTriggered: if (mainWindow) mainWindow.gotoPrevMarker() }
            Action { text: qsTr("Clear All Markers");        onTriggered: if (appState) appState.clearMarkers() }
        }
        MenuSeparator {}
        Action { text: qsTr("Keyboard Shortcuts…");      shortcut: "Ctrl+Alt+K";       onTriggered: menuHost.openSettingsToTab(7) }
        Action { text: qsTr("Preferences…");             shortcut: "F12";              onTriggered: menuHost.openSettingsWindow() }
    }

    // ── COMPOSITION (AE) ─────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Composition")
        Action { text: qsTr("New Composition…");         shortcut: "Ctrl+N";        enabled: false }
        Action {
            text: qsTr("Composition Settings…")
            shortcut: "Ctrl+K"
            onTriggered: menuHost.openCompositionSettingsDialog()
        }
        Action { text: qsTr("Set Poster Time");          enabled: false }
        Action { text: qsTr("Trim Comp to Work Area");   enabled: false }
        Action { text: qsTr("Crop Comp to Region of Interest"); enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Add to Render Queue");      shortcut: "Ctrl+Shift+M";  enabled: false }
        Action { text: qsTr("Add to Render Queue…");             shortcut: "Ctrl+Alt+M"; onTriggered: menuHost.openRenderQueuePanel() }
        Action { text: qsTr("Add Output Module");        enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Preview");                  shortcut: "Space";         onTriggered: if (mainWindow) mainWindow.togglePlayback() }
        Action { text: qsTr("Save Frame As");            enabled: false }
        Action { text: qsTr("Pre-render…");              enabled: false }
        Action { text: qsTr("Save Current Preview…");    enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Open in Essential Graphics"); enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Responsive Design — Time"); enabled: false }
        Action { text: qsTr("Composition Flowchart");    enabled: false }
        Action { text: qsTr("Composition Mini-Flowchart"); shortcut: "Tab"; enabled: false }
        MenuSeparator {}
        Action { text: qsTr("VR");                       enabled: false }
    }

    // ── LAYER (AE) ───────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Layer")
        Menu {
            title: qsTr("New")
            Action { text: qsTr("Text");                 shortcut: "Ctrl+T";        onTriggered: if (mainWindow) mainWindow.addTextLayer("Text") }
            Action { text: qsTr("Solid…");               shortcut: "Ctrl+Y";        onTriggered: if (mainWindow) mainWindow.addSolidLayer("Solid") }
            Action { text: qsTr("Light…");               onTriggered: if (mainWindow) mainWindow.addLightLayer("Light") }
            Action { text: qsTr("Camera…");              onTriggered: if (mainWindow) mainWindow.addCameraLayer("Camera") }
            Action { text: qsTr("Null Object");          shortcut: "Ctrl+Alt+Shift+Y"; enabled: false }
            Action { text: qsTr("Shape Layer");          onTriggered: if (mainWindow) mainWindow.addShapeLayer("rect") }
            Action { text: qsTr("Adjustment Layer");     shortcut: "Ctrl+Alt+Y";    onTriggered: if (mainWindow) mainWindow.addAdjustmentLayer() }
            Action { text: qsTr("Image Layer…");          onTriggered: menuHost.openImportDialog() }
            Action { text: qsTr("Content-Aware Fill Layer"); enabled: false }
        }
        Action { text: qsTr("Layer Settings…");          shortcut: "Ctrl+Shift+Y";  enabled: false }
        Action { text: qsTr("Open Layer");               enabled: false }
        Action { text: qsTr("Open Layer Source");        enabled: false }
        Action { text: qsTr("Reveal in Explorer");       enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Mask");                     enabled: false }
        Action { text: qsTr("Mask and Shape Path");      enabled: false }
        Action { text: qsTr("Quality");                  enabled: false }
        Action { text: qsTr("Switches");                 enabled: false }
        Menu {
            title: qsTr("Transform")
            Action { text: qsTr("Reset");                enabled: false }
            Action { text: qsTr("Anchor Point");         shortcut: "A";             enabled: false }
            Action { text: qsTr("Position");             shortcut: "P";             enabled: false }
            Action { text: qsTr("Scale");                shortcut: "S";             enabled: false }
            Action { text: qsTr("Rotation");             shortcut: "R";             enabled: false }
            Action { text: qsTr("Opacity");              shortcut: "T";             enabled: false }
        }
        Action { text: qsTr("Time");                     enabled: false }
        Action { text: qsTr("Frame Blending");           enabled: false }
        Action { text: qsTr("3D Layer");                 enabled: false }
        Action { text: qsTr("Guide Layer");              enabled: false }
        Action { text: qsTr("Environment Layer");        enabled: false }
        Action { text: qsTr("Markers");                  enabled: false }
        Action { text: qsTr("Preserve Transparency");    enabled: false }
        Menu {
            title: qsTr("Blending Mode")
            Action { text: qsTr("Normal");               enabled: false }
            Action { text: qsTr("Dissolve");             enabled: false }
            Action { text: qsTr("Multiply");             enabled: false }
            Action { text: qsTr("Screen");               enabled: false }
            Action { text: qsTr("Overlay");              enabled: false }
            Action { text: qsTr("Add");                  enabled: false }
            Action { text: qsTr("Difference");           enabled: false }
        }
        Action { text: qsTr("Next Blending Mode");       shortcut: "Shift+–";       enabled: false }
        Action { text: qsTr("Previous Blending Mode");   shortcut: "Shift+=";       enabled: false }
        Action { text: qsTr("Track Matte");              enabled: false }
        Action { text: qsTr("Layer Styles");             enabled: false }
        Action { text: qsTr("Arrange");                  enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Camera");                   enabled: false }
        Action { text: qsTr("Light");                    enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Auto-trace…");              enabled: false }
        Action { text: qsTr("Pre-compose…");             shortcut: "Ctrl+Shift+C";  enabled: false }
        Action { text: qsTr("Scene Edit Detection…");    enabled: false }
        Menu {
            title: qsTr("Animation")
            Action { text: qsTr("Save Animation Preset…");   enabled: false }
            Action { text: qsTr("Apply Animation Preset…");  enabled: false }
            Action { text: qsTr("Recent Animation Presets"); enabled: false }
            Action { text: qsTr("Browse Presets…");          enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Set Keyframe");             enabled: false }
            Action { text: qsTr("Toggle Hold Keyframe");     shortcut: "Ctrl+Alt+H"; enabled: false }
            Action { text: qsTr("Keyframe Interpolation…");  shortcut: "Ctrl+Alt+K"; enabled: false }
            Action { text: qsTr("Keyframe Velocity…");       shortcut: "Ctrl+Shift+K"; enabled: false }
            Menu {
                title: qsTr("Keyframe Assistant")
                Action { text: qsTr("Convert Expression to Keyframes"); enabled: false }
                Action { text: qsTr("Easy Ease");            shortcut: "F9";        enabled: false }
                Action { text: qsTr("Easy Ease In");         shortcut: "Ctrl+F9";   enabled: false }
                Action { text: qsTr("Easy Ease Out");        shortcut: "Ctrl+Shift+F9"; enabled: false }
                Action { text: qsTr("Exponential Scale");    enabled: false }
                Action { text: qsTr("RPF Camera Import");    enabled: false }
                Action { text: qsTr("Sequence Layers…");     enabled: false }
                Action { text: qsTr("Time-Reverse Keyframes"); enabled: false }
            }
            MenuSeparator {}
            Action { text: qsTr("Add Property to Essential Graphics"); enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Animate Text");             enabled: false }
            Action { text: qsTr("Add Text Selector");        enabled: false }
            Action { text: qsTr("Remove All Text Animators"); enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Add Expression");           shortcut: "Alt+Shift+–"; enabled: false }
            Action { text: qsTr("Separate Dimensions");      enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Track Camera");             enabled: false }
            Action { text: qsTr("Warp Stabilizer VFX");      enabled: false }
            Action { text: qsTr("Track Motion");             enabled: false }
            Action { text: qsTr("Track Mask");               enabled: false }
            Action { text: qsTr("Track this Property");      enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Reveal Properties with Keyframes"); shortcut: "U";  enabled: false }
            Action { text: qsTr("Reveal Properties with Animation"); shortcut: "UU"; enabled: false }
            Action { text: qsTr("Reveal All Modified Properties");   enabled: false }
        }
        Menu {
            title: qsTr("Graphics")
            Action { text: qsTr("Install Motion Graphics Template…"); enabled: false }
            MenuSeparator {}
            Menu {
                title: qsTr("New Layer")
                Action { text: qsTr("Text");                 onTriggered: if (mainWindow) mainWindow.addTextLayer("Text") }
                Action { text: qsTr("Rectangle");            onTriggered: if (mainWindow) mainWindow.addShapeLayer("rect") }
                Action { text: qsTr("Ellipse");              onTriggered: if (mainWindow) mainWindow.addShapeLayer("ellipse") }
                Action { text: qsTr("From File…");           enabled: false }
            }
            MenuSeparator {}
            Action { text: qsTr("Align to Video Frame");     enabled: false }
            Action { text: qsTr("Align to Video Frame as Group"); enabled: false }
            Action { text: qsTr("Align to Selection");       enabled: false }
            Action { text: qsTr("Distribute");               enabled: false }
            Action { text: qsTr("Arrange");                  enabled: false }
            Action { text: qsTr("Select");                   enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Upgrade to Source Graphic"); enabled: false }
            Action { text: qsTr("Upgrade Caption to Graphic"); enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Reset All Parameters");     enabled: false }
            Action { text: qsTr("Reset Duration");           enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Export As Motion Graphics Template…"); enabled: false }
            Action { text: qsTr("Replace Fonts in Projects…"); enabled: false }
        }
    }

    // ── EFFECT (AE) ──────────────────────────────────────────────────────────
    Menu {
        title: qsTr("Effect")
        Action { text: qsTr("Effect Controls");          shortcut: "F3";            enabled: false }
        Action { text: qsTr("Last Effect");              enabled: false }
        Action { text: qsTr("Remove All");               enabled: false }
        Action { text: qsTr("Manage Effects…");          enabled: false }
        MenuSeparator {}
        Menu {
            title: qsTr("3D Channel")
            Action { text: qsTr("3D Channel Extract");    enabled: false }
            Action { text: qsTr("Depth Matte");           enabled: false }
            Action { text: qsTr("Depth of Field");        enabled: false }
            Action { text: qsTr("EXtractoR");             enabled: false }
            Action { text: qsTr("Fog 3D");                enabled: false }
        }
        Menu {
            title: qsTr("Audio")
            Action { text: qsTr("Backwards");            enabled: false }
            Action { text: qsTr("Bass & Treble");        enabled: false }
            Action { text: qsTr("Delay");                enabled: false }
            Action { text: qsTr("Flange & Chorus");      enabled: false }
            Action { text: qsTr("High-Low Pass");        enabled: false }
            Action { text: qsTr("Modulator");            enabled: false }
            Action { text: qsTr("Parametric EQ");        enabled: false }
            Action { text: qsTr("Reverb");               enabled: false }
            Action { text: qsTr("Stereo Mixer");         enabled: false }
            Action { text: qsTr("Tone");                 enabled: false }
        }
        Menu {
            title: qsTr("Blur & Sharpen")
            Action { text: qsTr("Bilateral Blur");       enabled: false }
            Action { text: qsTr("Camera Lens Blur");     enabled: false }
            Action { text: qsTr("Camera-Shake Deblur");  enabled: false }
            Action { text: qsTr("CC Cross Blur");        enabled: false }
            Action { text: qsTr("CC Radial Blur");       enabled: false }
            Action { text: qsTr("CC Radial Fast Blur");  enabled: false }
            Action { text: qsTr("CC Vector Blur");       enabled: false }
            Action { text: qsTr("Channel Blur");         enabled: false }
            Action { text: qsTr("Compound Blur");        enabled: false }
            Action { text: qsTr("Directional Blur");     enabled: false }
            Action { text: qsTr("Fast Box Blur");        enabled: false }
            Action { text: qsTr("Gaussian Blur");        enabled: false }
            Action { text: qsTr("Radial Blur");          enabled: false }
            Action { text: qsTr("Reduce Interlace Flicker"); enabled: false }
            Action { text: qsTr("Sharpen");              enabled: false }
            Action { text: qsTr("Smart Blur");           enabled: false }
            Action { text: qsTr("Unsharp Mask");         enabled: false }
        }
        Menu {
            title: qsTr("Channel")
            Action { text: qsTr("Arithmetic");           enabled: false }
            Action { text: qsTr("Blend");                enabled: false }
            Action { text: qsTr("Calculations");         enabled: false }
            Action { text: qsTr("Channel Combiner");     enabled: false }
            Action { text: qsTr("Compound Arithmetic");  enabled: false }
            Action { text: qsTr("Invert");               enabled: false }
            Action { text: qsTr("Minimax");              enabled: false }
            Action { text: qsTr("Remove Color Matting"); enabled: false }
            Action { text: qsTr("Set Channels");         enabled: false }
            Action { text: qsTr("Set Matte");            enabled: false }
            Action { text: qsTr("Shift Channels");       enabled: false }
            Action { text: qsTr("Solid Composite");      enabled: false }
        }
        Menu {
            title: qsTr("Color Correction")
            Action { text: qsTr("Auto Color");           enabled: false }
            Action { text: qsTr("Auto Contrast");        enabled: false }
            Action { text: qsTr("Auto Levels");          enabled: false }
            Action { text: qsTr("Black & White");        enabled: false }
            Action { text: qsTr("Brightness & Contrast"); enabled: false }
            Action { text: qsTr("Change Color");         enabled: false }
            Action { text: qsTr("Change to Color");      enabled: false }
            Action { text: qsTr("Channel Mixer");        enabled: false }
            Action { text: qsTr("Color Balance");        enabled: false }
            Action { text: qsTr("Color Link");           enabled: false }
            Action { text: qsTr("Color Stabilizer");     enabled: false }
            Action { text: qsTr("Colorama");             enabled: false }
            Action { text: qsTr("Curves");               enabled: false }
            Action { text: qsTr("Equalize");             enabled: false }
            Action { text: qsTr("Exposure");             enabled: false }
            Action { text: qsTr("Gamma/Pedestal/Gain");  enabled: false }
            Action { text: qsTr("Hue/Saturation");       enabled: false }
            Action { text: qsTr("Leave Color");          enabled: false }
            Action { text: qsTr("Levels");               enabled: false }
            Action { text: qsTr("Levels (Individual Controls)"); enabled: false }
            Action { text: qsTr("Lumetri Color");        enabled: false }
            Action { text: qsTr("Photo Filter");         enabled: false }
            Action { text: qsTr("PS Arbitrary Map");     enabled: false }
            Action { text: qsTr("Selective Color");      enabled: false }
            Action { text: qsTr("Shadow/Highlight");     enabled: false }
            Action { text: qsTr("Tint");                 enabled: false }
            Action { text: qsTr("Tritone");              enabled: false }
            Action { text: qsTr("Vibrance");             enabled: false }
        }
        Menu {
            title: qsTr("Distort")
            Action { text: qsTr("Bezier Warp");          enabled: false }
            Action { text: qsTr("Bulge");                enabled: false }
            Action { text: qsTr("Corner Pin");           enabled: false }
            Action { text: qsTr("Displacement Map");     enabled: false }
            Action { text: qsTr("Liquify");              enabled: false }
            Action { text: qsTr("Magnify");              enabled: false }
            Action { text: qsTr("Mesh Warp");            enabled: false }
            Action { text: qsTr("Mirror");               enabled: false }
            Action { text: qsTr("Offset");               enabled: false }
            Action { text: qsTr("Optics Compensation");  enabled: false }
            Action { text: qsTr("Polar Coordinates");    enabled: false }
            Action { text: qsTr("Ripple");               enabled: false }
            Action { text: qsTr("Rolling Shutter Repair"); enabled: false }
            Action { text: qsTr("Smear");                enabled: false }
            Action { text: qsTr("Spherize");             enabled: false }
            Action { text: qsTr("Transform");            enabled: false }
            Action { text: qsTr("Turbulent Displace");   enabled: false }
            Action { text: qsTr("Twirl");                enabled: false }
            Action { text: qsTr("Warp");                 enabled: false }
            Action { text: qsTr("Warp Stabilizer VFX");  enabled: false }
            Action { text: qsTr("Wave Warp");            enabled: false }
        }
        Menu {
            title: qsTr("Expression Controls")
            Action { text: qsTr("Angle Control");        enabled: false }
            Action { text: qsTr("Checkbox Control");     enabled: false }
            Action { text: qsTr("Color Control");        enabled: false }
            Action { text: qsTr("Layer Control");        enabled: false }
            Action { text: qsTr("Point Control");        enabled: false }
            Action { text: qsTr("Slider Control");       enabled: false }
        }
        Menu {
            title: qsTr("Generate")
            Action { text: qsTr("4-Color Gradient");     enabled: false }
            Action { text: qsTr("Advanced Lightning");   enabled: false }
            Action { text: qsTr("Audio Spectrum");       enabled: false }
            Action { text: qsTr("Audio Waveform");       enabled: false }
            Action { text: qsTr("Beam");                 enabled: false }
            Action { text: qsTr("Cell Pattern");         enabled: false }
            Action { text: qsTr("Checkerboard");         enabled: false }
            Action { text: qsTr("Circle");               enabled: false }
            Action { text: qsTr("Ellipse");              enabled: false }
            Action { text: qsTr("Eyedropper Fill");      enabled: false }
            Action { text: qsTr("Fill");                 enabled: false }
            Action { text: qsTr("Fractal");              enabled: false }
            Action { text: qsTr("Gradient Ramp");        enabled: false }
            Action { text: qsTr("Grid");                 enabled: false }
            Action { text: qsTr("Lens Flare");           enabled: false }
            Action { text: qsTr("Lightning");            enabled: false }
            Action { text: qsTr("Scribble");             enabled: false }
            Action { text: qsTr("Stroke");               enabled: false }
            Action { text: qsTr("Vegas");                enabled: false }
            Action { text: qsTr("Write-on");             enabled: false }
        }
        Menu {
            title: qsTr("Keying")
            Action { text: qsTr("Color Difference Key"); enabled: false }
            Action { text: qsTr("Color Range");          enabled: false }
            Action { text: qsTr("Difference Matte");     enabled: false }
            Action { text: qsTr("Extract");              enabled: false }
            Action { text: qsTr("Inner/Outer Key");      enabled: false }
            Action { text: qsTr("Key Cleaner");          enabled: false }
            Action { text: qsTr("Keylight (1.2)");       enabled: false }
            Action { text: qsTr("Linear Color Key");     enabled: false }
            Action { text: qsTr("Luma Key");             enabled: false }
            Action { text: qsTr("Spill Suppressor");     enabled: false }
            Action { text: qsTr("Ultra Key");            enabled: false }
        }
        Menu {
            title: qsTr("Noise & Grain")
            Action { text: qsTr("Add Grain");            enabled: false }
            Action { text: qsTr("Dust & Scratches");     enabled: false }
            Action { text: qsTr("Fractal Noise");        enabled: false }
            Action { text: qsTr("Match Grain");          enabled: false }
            Action { text: qsTr("Median");               enabled: false }
            Action { text: qsTr("Noise");                enabled: false }
            Action { text: qsTr("Noise Alpha");          enabled: false }
            Action { text: qsTr("Noise HLS");            enabled: false }
            Action { text: qsTr("Remove Grain");         enabled: false }
            Action { text: qsTr("Turbulent Noise");      enabled: false }
        }
        Menu {
            title: qsTr("Perspective")
            Action { text: qsTr("3D Camera Tracker");    enabled: false }
            Action { text: qsTr("Bevel Alpha");          enabled: false }
            Action { text: qsTr("Bevel Edges");          enabled: false }
            Action { text: qsTr("Drop Shadow");          enabled: false }
            Action { text: qsTr("Environment Layer");    enabled: false }
            Action { text: qsTr("Radial Shadow");        enabled: false }
        }
        Menu {
            title: qsTr("Simulation")
            Action { text: qsTr("Card Dance");           enabled: false }
            Action { text: qsTr("Caustics");             enabled: false }
            Action { text: qsTr("Foam");                 enabled: false }
            Action { text: qsTr("Particle Playground");  enabled: false }
            Action { text: qsTr("Shatter");              enabled: false }
            Action { text: qsTr("Wave World");           enabled: false }
        }
        Menu {
            title: qsTr("Stylize")
            Action { text: qsTr("Brush Strokes");        enabled: false }
            Action { text: qsTr("Cartoon");              enabled: false }
            Action { text: qsTr("Color Emboss");         enabled: false }
            Action { text: qsTr("Emboss");               enabled: false }
            Action { text: qsTr("Find Edges");           enabled: false }
            Action { text: qsTr("Glow");                 enabled: false }
            Action { text: qsTr("Leave Color");          enabled: false }
            Action { text: qsTr("Mosaic");               enabled: false }
            Action { text: qsTr("Motion Tile");          enabled: false }
            Action { text: qsTr("Posterize");            enabled: false }
            Action { text: qsTr("Roughen Edges");        enabled: false }
            Action { text: qsTr("Scatter");              enabled: false }
            Action { text: qsTr("Strobe Light");         enabled: false }
            Action { text: qsTr("Texturize");            enabled: false }
            Action { text: qsTr("Threshold");            enabled: false }
        }
        Menu {
            title: qsTr("Transition")
            Action { text: qsTr("Block Dissolve");       enabled: false }
            Action { text: qsTr("Card Wipe");            enabled: false }
            Action { text: qsTr("Gradient Wipe");        enabled: false }
            Action { text: qsTr("Iris Wipe");            enabled: false }
            Action { text: qsTr("Linear Wipe");          enabled: false }
            Action { text: qsTr("Radial Wipe");          enabled: false }
            Action { text: qsTr("Venetian Blinds");      enabled: false }
        }
        Menu {
            title: qsTr("Utility")
            Action { text: qsTr("Apply Color LUT");      enabled: false }
            Action { text: qsTr("Cineon Converter");     enabled: false }
            Action { text: qsTr("Color Profile Converter"); enabled: false }
            Action { text: qsTr("Grow Bounds");          enabled: false }
            Action { text: qsTr("HDR Compander");        enabled: false }
            Action { text: qsTr("HDR Highlight Compression"); enabled: false }
        }
    }

    // ── VIEW ─────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&View")
        Menu {
            title: qsTr("Playback")
            Action { text: qsTr("Play / Pause");             shortcut: "Space";         onTriggered: if (mainWindow) mainWindow.togglePlayback() }
            Action { text: qsTr("Stop");                     shortcut: "K";             onTriggered: if (mainWindow) mainWindow.stop() }
            Action { text: qsTr("Play In to Out");           shortcut: "Shift+Space";   enabled: false }
            Action { text: qsTr("Loop");                     enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Go to Beginning");          shortcut: "Home";          onTriggered: if (mainWindow) mainWindow.gotoStart() }
            Action { text: qsTr("Go to End");                shortcut: "End";           onTriggered: if (mainWindow) mainWindow.gotoEnd() }
            Action { text: qsTr("Step Back 1 Frame");        shortcut: "Left";          onTriggered: if (mainWindow) mainWindow.stepFrame(-1) }
            Action { text: qsTr("Step Forward 1 Frame");     shortcut: "Right";         onTriggered: if (mainWindow) mainWindow.stepFrame(+1) }
            Action { text: qsTr("Step Back 10 Frames");      shortcut: "Shift+Left";    onTriggered: if (mainWindow) mainWindow.stepFrame(-10) }
            Action { text: qsTr("Step Forward 10 Frames");   shortcut: "Shift+Right";   onTriggered: if (mainWindow) mainWindow.stepFrame(+10) }
            Action { text: qsTr("Fast Forward");             shortcut: "L";             onTriggered: if (mainWindow) mainWindow.nudgePlaybackRate(+1) }
            Action { text: qsTr("Rewind");                   shortcut: "J";             onTriggered: if (mainWindow) mainWindow.nudgePlaybackRate(-1) }
            MenuSeparator {}
            Menu {
                title: qsTr("Playback Resolution")
                Action { text: qsTr("Full");    onTriggered: if (mainWindow) mainWindow.previewQuality = "Full" }
                Action { text: qsTr("Half");    onTriggered: if (mainWindow) mainWindow.previewQuality = "Half" }
                Action { text: qsTr("Quarter"); onTriggered: if (mainWindow) mainWindow.previewQuality = "Quarter" }
            }
            Action { text: qsTr("Full Screen Preview");      shortcut: "Ctrl+Shift+F";  onTriggered: menuHost.visibility === Window.FullScreen ? menuHost.showNormal() : menuHost.showFullScreen() }
        }
        Menu {
            title: qsTr("Playback Resolution")
            Action { text: qsTr("Full");    onTriggered: if (mainWindow) mainWindow.previewQuality = "Full" }
            Action { text: qsTr("Half");    onTriggered: if (mainWindow) mainWindow.previewQuality = "Half" }
            Action { text: qsTr("Quarter"); onTriggered: if (mainWindow) mainWindow.previewQuality = "Quarter" }
        }
        Menu {
            title: qsTr("Paused Resolution")
            Action { text: qsTr("Full");    enabled: false }
            Action { text: qsTr("Half");    enabled: false }
        }
        Action { text: qsTr("High Quality Playback");    enabled: false }
        Menu {
            title: qsTr("Display Mode")
            Action { text: qsTr("Composite");            enabled: false }
            Action { text: qsTr("Alpha");                enabled: false }
            Action { text: qsTr("All Channels View");    enabled: false }
        }
        Menu {
            title: qsTr("Magnification")
            Action { text: qsTr("Fit");                  enabled: false }
            Action { text: qsTr("50%");                  enabled: false }
            Action { text: qsTr("100%");                 enabled: false }
            Action { text: qsTr("200%");                 enabled: false }
        }
        MenuSeparator {}
        Action { text: qsTr("Show Rulers");              shortcut: "Ctrl+R";        enabled: false }
        Action { text: qsTr("Show Guides");              shortcut: "Ctrl+;";        enabled: false }
        Action { text: qsTr("Lock Guides");              shortcut: "Ctrl+Alt+;";    enabled: false }
        Action { text: qsTr("Add Guide…");               enabled: false }
        Action { text: qsTr("Clear Guides");             enabled: false }
        Action { text: qsTr("Import Guides…");           enabled: false }
        Action { text: qsTr("Export Guides…");           enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Show Grid");                shortcut: "Ctrl+'";        enabled: false }
        Action { text: qsTr("Snap to Grid");             shortcut: "Ctrl+Shift+'";  enabled: false }
        Action { text: qsTr("View Options…");            enabled: false }
        Action { text: qsTr("Show Layer Controls");      shortcut: "Ctrl+Shift+H";  enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Snap in Program Monitor");  enabled: false }
        Action { text: qsTr("Safe Zones");               enabled: false }
        Menu {
            title: qsTr("Guide Templates")
            Action { text: qsTr("Action Safe / Title Safe"); enabled: false }
            Action { text: qsTr("Center Cross");         enabled: false }
        }
        MenuSeparator {}
        Menu {
            title: qsTr("Workspace")
            Action { text: qsTr("Standard");             onTriggered: if (mainWindow) mainWindow.workspace = "Standard" }
            Action { text: qsTr("Editing");              onTriggered: if (mainWindow) mainWindow.workspace = "Editing" }
            Action { text: qsTr("Color");                onTriggered: if (mainWindow) mainWindow.workspace = "Color" }
            Action { text: qsTr("Motion Tracking");      onTriggered: if (mainWindow) mainWindow.workspace = "Motion Tracking" }
            Action { text: qsTr("VFX");                  onTriggered: if (mainWindow) mainWindow.workspace = "VFX" }
            Action { text: qsTr("Audio");                enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Save Workspace…");      enabled: false }
            Action { text: qsTr("Delete Workspace…");    enabled: false }
            Action { text: qsTr("Reset to Saved Layout"); enabled: false }
        }
        MenuSeparator {}
        Action { text: qsTr("Zoom In");                  shortcut: "+";             enabled: false }
        Action { text: qsTr("Zoom Out");                 shortcut: "-";             enabled: false }
        Action { text: qsTr("Go to Time…");              shortcut: "Ctrl+G";        enabled: false }
    }

    // ── TIMELINE ──────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Timeline")
        Action {
            text: qsTr("Split at Playhead")
            shortcut: "Ctrl+K"
            onTriggered: if (mainWindow) mainWindow.splitAtPlayhead()
        }
        Action {
            text: qsTr("Add Marker")
            shortcut: "M"
            onTriggered: if (mainWindow) mainWindow.addMarkerAtPlayhead()
        }
        MenuSeparator {}
        Action {
            text: qsTr("Timeline Effects")
            shortcut: "Ctrl+4"
            onTriggered: if (menuHost.editor) menuHost.editor.focusEffectsPanel()
        }
        Action {
            text: qsTr("Color Effects")
            onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(11)
        }
        Action {
            text: qsTr("Audio Effects")
            onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(22)
        }
    }

    // ── WINDOW ────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Window")
        Menu {
            title: qsTr("Workspaces")
            Action { text: qsTr("Standard");             onTriggered: if (mainWindow) mainWindow.workspace = "Standard" }
            Action { text: qsTr("Editing");              onTriggered: if (mainWindow) mainWindow.workspace = "Editing" }
            Action { text: qsTr("Color");                onTriggered: if (mainWindow) mainWindow.workspace = "Color" }
            Action { text: qsTr("VFX");                  onTriggered: if (mainWindow) mainWindow.workspace = "VFX" }
            Action { text: qsTr("Audio");                enabled: false }
            MenuSeparator {}
            Action { text: qsTr("Save as New Workspace…"); enabled: false }
            Action { text: qsTr("Edit Workspaces…");     enabled: false }
        }
        Action { text: qsTr("Find Extensions on Exchange…"); enabled: false }
        Action { text: qsTr("Maximize Frame");           shortcut: "`";             enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Media Pool");               shortcut: "Ctrl+1";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(1) }
        Action { text: qsTr("Source Monitor");           shortcut: "Ctrl+2";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(2) }
        Action { text: qsTr("Program Monitor / Preview"); shortcut: "Ctrl+Shift+2"; onTriggered: if (menuHost.editor) menuHost.editor.emphasizePreview() }
        Action { text: qsTr("Timeline");                 shortcut: "Ctrl+3";        onTriggered: if (menuHost.editor) menuHost.editor.emphasizeTimeline() }
        Action { text: qsTr("Effects");                  shortcut: "Ctrl+4";        onTriggered: if (menuHost.editor) menuHost.editor.focusEffectsPanel() }
        Action { text: qsTr("Color / Lumetri");          shortcut: "Ctrl+5";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(11) }
        Action { text: qsTr("Audio Mixer");              shortcut: "Ctrl+6";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(22) }
        Action { text: qsTr("AI Agent");                 shortcut: "Ctrl+7";        onTriggered: menuHost.focusAiChat() }
        Action { text: qsTr("Properties");               shortcut: "Ctrl+8";        onTriggered: if (menuHost.editor) menuHost.editor.openMidInspector() }
        Action { text: qsTr("Scopes");                   shortcut: "Ctrl+9";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(12) }
        Action { text: qsTr("Keyframe Graph Editor");    shortcut: "Ctrl+0";        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(16) }
        MenuSeparator {}
        Action { text: qsTr("Markers");                  onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(24) }
        Action { text: qsTr("History");                  onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(25) }
        Action { text: qsTr("Render Queue");             onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(26) }
        Action { text: qsTr("Inspector");                onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(27) }
        Action { text: qsTr("Titles & Graphics");        onTriggered: if (menuHost.editor) menuHost.editor.openLeftDockPanel(9) }
        Action { text: qsTr("Collaboration");            enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Audio Clip Effect Editor"); enabled: false }
        Action { text: qsTr("Audio Track Effect Editor"); enabled: false }
        Action { text: qsTr("Progress");                 enabled: false }
        Action { text: qsTr("Text");                     enabled: false }
        MenuSeparator {}
        Action {
            text: qsTr("Reset Window Layout")
            shortcut: "Ctrl+Alt+0"
            onTriggered: {
                if (mainWindow && typeof mainWindow.resetEditorLayout === "function")
                    mainWindow.resetEditorLayout()
                menuHost.resetWindowLayout()
            }
        }
    }

    // ── AI ────────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&AI")
        Action { text: qsTr("Open AI Agent");            shortcut: "Ctrl+Shift+A";     onTriggered: menuHost.focusAiChat() }
        Action { text: qsTr("Quick Command…");           shortcut: "Ctrl+Shift+Space"; onTriggered: menuHost.focusAiChat() }
        MenuSeparator {}
        Action { text: qsTr("Auto Edit Selection");      shortcut: "Alt+A"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Auto-edit the selected clips") }
        Action { text: qsTr("Auto Color Grade");         shortcut: "Alt+C"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Auto color grade all clips professionally") }
        Action { text: qsTr("Remove Silences");          shortcut: "Alt+S"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Remove all silences from the timeline automatically") }
        Action { text: qsTr("Beat Sync");                shortcut: "Alt+B"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Sync cuts to the music beats on the audio track") }
        Action { text: qsTr("Generate Captions");        shortcut: "Alt+T"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Generate and add captions/subtitles to the video") }
        Action { text: qsTr("Analyze Footage");          shortcut: "Alt+R"; onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Analyze footage and suggest the best edit points") }
        MenuSeparator {}
        Action { text: qsTr("Upscale to 4K");            onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Upscale all clips to 4K resolution using AI") }
        Action { text: qsTr("Remove Background");        onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Remove background from selected clip using AI") }
        Action { text: qsTr("Stabilize Footage");        onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Apply AI stabilization to shaky footage clips") }
        Action { text: qsTr("Noise Reduction");          onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Apply AI noise reduction to all video clips") }
        Action { text: qsTr("Audio Denoise");            onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Remove background noise from all audio clips") }
        Action { text: qsTr("Style Transfer");           onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Apply a cinematic style transfer to the footage") }
        Action { text: qsTr("Generate Music");           onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Generate background music for the timeline") }
        Action { text: qsTr("Face Refinement");          onTriggered: if (mainWindow) mainWindow.submitAiPrompt("Apply AI face refinement to talking-head clips") }
        MenuSeparator {}
        Action { text: qsTr("Undo Last AI Edit");        onTriggered: if (mainWindow) mainWindow.undoLastAiCommand() }
        Action { text: qsTr("View AI History");          onTriggered: menuHost.focusAiChat() }
        Action { text: qsTr("AI Settings…");             onTriggered: menuHost.openSettingsToTab(3) }
    }

    // ── HELP ─────────────────────────────────────────────────────────────────
    Menu {
        title: qsTr("&Help")
        Action { text: qsTr("Fognitix Help");            shortcut: "F1";            enabled: false }
        Action { text: qsTr("Fognitix In-App Tutorials…"); enabled: false }
        Action { text: qsTr("Fognitix Online Tutorials…"); enabled: false }
        Action { text: qsTr("Scripting Reference…");     enabled: false }
        Action { text: qsTr("Expression Reference…");    enabled: false }
        Action { text: qsTr("Effect Reference…");        enabled: false }
        Action { text: qsTr("Animation Presets…");       enabled: false }
        Action { text: qsTr("Keyboard Shortcuts…");      shortcut: "Ctrl+Alt+K";    onTriggered: menuHost.openSettingsToTab(7) }
        MenuSeparator {}
        Action { text: qsTr("System Compatibility Report…"); enabled: false }
        Action { text: qsTr("Enable Logging");           enabled: false }
        Action { text: qsTr("Reveal Logging File");      enabled: false }
        MenuSeparator {}
        Action { text: qsTr("Online User Forums…");      enabled: false }
        Action { text: qsTr("Provide Feedback…");        enabled: false }
        Action { text: qsTr("Check for Updates…");       enabled: false }
        Action { text: qsTr("Release Notes");            enabled: false }
        MenuSeparator {}
        Action { text: qsTr("About Fognitix…");          onTriggered: menuHost.openAboutDialog() }
    }
}
