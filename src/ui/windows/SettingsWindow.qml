import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Window {
    id: root
    title: qsTr("Settings — Fognitix")
    width: 820; height: 620
    minimumWidth: 680; minimumHeight: 500
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: theme.colors.primaryBackground

    Theme { id: theme }

    property int currentTab: 0
    readonly property var tabs: [
        qsTr("General"), qsTr("Appearance"), qsTr("Playback"),
        qsTr("AI"),       qsTr("Performance"), qsTr("Export"),
        qsTr("Audio"),    qsTr("Shortcuts")
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left nav
        Rectangle {
            Layout.preferredWidth: 170
            Layout.fillHeight: true
            color: theme.colors.secondaryPanel

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 8; spacing: 8
                        Rectangle { width: 20; height: 16; radius: 3; color: theme.colors.accent
                            Label { anchors.centerIn: parent; text: "Fx"; color: "#fff"; font.pixelSize: 9; font.weight: Font.Bold }
                        }
                        Label { text: qsTr("Settings"); color: theme.colors.textPrimary; font.pixelSize: 13; font.weight: Font.Medium }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSubtle }
                Item { height: 4 }

                Repeater {
                    model: root.tabs
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 32; radius: 5
                        color: root.currentTab === index ? theme.colors.accentMuted
                             : navMA.containsMouse ? theme.colors.tertiaryPanel : "transparent"
                        border.color: root.currentTab === index ? theme.colors.accent : "transparent"
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left; anchors.leftMargin: 12
                            text: modelData
                            color: root.currentTab === index ? theme.colors.textPrimary : theme.colors.textSecondary
                            font.pixelSize: 12
                            font.weight: root.currentTab === index ? Font.Medium : Font.Normal
                        }
                        MouseArea { id: navMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = index }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: theme.colors.borderColor }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            Rectangle {
                Layout.fillWidth: true; height: 40; color: theme.colors.panelBackground
                Label {
                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 20
                    text: root.tabs[root.currentTab]
                    color: theme.colors.textPrimary; font.pixelSize: 15; font.weight: Font.Medium
                }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true
                contentWidth: availableWidth; clip: true
                ScrollBar.vertical.contentItem: Rectangle { color: theme.colors.scrollbar; radius: 3; implicitWidth: 6 }
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                StackLayout {
                    width: parent.width
                    currentIndex: root.currentTab

                    // ── General ──────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Project")
                            SRow { label: qsTr("Auto-save interval");  SSlider { from: 1; to: 30; value: 5; suffix: qsTr(" min") } }
                            SRow { label: qsTr("Undo history limit");  SSlider { from: 10; to: 500; value: 200; stepSize: 10; suffix: qsTr(" steps") } }
                            SRow { label: qsTr("Recent projects count"); SSlider { from: 5; to: 30; value: 10; stepSize: 1; suffix: "" } }
                            SRow { label: qsTr("Startup");  SCombo { model: [qsTr("Welcome screen"), qsTr("Open last project"), qsTr("New project")] } }
                        }
                        SGroup { title: qsTr("Cache & Scratch")
                            SRow { label: qsTr("Cache size"); SSlider { from: 1; to: 64; value: 8; suffix: " GB" } }
                            SRow { label: qsTr("Thumbnail quality"); SCombo { model: [qsTr("Low"), qsTr("Medium"), qsTr("High")]; currentIndex: 1 } }
                            SRow { label: qsTr("Clear cache on exit"); SCheck { checked: false } }
                        }
                        Item { height: 20 }
                    }

                    // ── Appearance ───────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Theme")
                            SRow {
                                label: qsTr("UI theme")
                                SCombo {
                                    id: palCombo
                                    model: [qsTr("Dark"), qsTr("Light")]
                                    Component.onCompleted: {
                                        if (mainWindow)
                                            currentIndex = mainWindow.uiPalette === "light" ? 1 : 0
                                    }
                                    Connections {
                                        target: mainWindow
                                        function onUiPaletteChanged() {
                                            if (mainWindow)
                                                palCombo.currentIndex = mainWindow.uiPalette === "light" ? 1 : 0
                                        }
                                    }
                                    onActivated: {
                                        if (mainWindow)
                                            mainWindow.uiPalette = (currentIndex === 1 ? "light" : "dark")
                                    }
                                }
                            }
                            SRow { label: qsTr("Font size"); SCombo { model: [qsTr("Small"), qsTr("Medium"), qsTr("Large")]; currentIndex: 1 } }
                        }
                        SGroup { title: qsTr("Timeline")
                            SRow { label: qsTr("Clip thumbnails");  SCheck { checked: true } }
                            SRow { label: qsTr("Waveform display"); SCheck { checked: true } }
                            SRow { label: qsTr("Waveform quality"); SCombo { model: [qsTr("Low"), qsTr("Medium"), qsTr("High")]; currentIndex: 1 } }
                            SRow { label: qsTr("Animation speed");  SCombo { model: [qsTr("None"), qsTr("Slow"), qsTr("Normal"), qsTr("Fast")]; currentIndex: 2 } }
                        }
                        Item { height: 20 }
                    }

                    // ── Playback ─────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Playback")
                            SRow { label: qsTr("Default quality"); SCombo { model: [qsTr("Auto"), qsTr("Full"), qsTr("Half"), qsTr("Quarter")] } }
                            SRow { label: qsTr("Preroll");  SSlider { from: 0; to: 10; value: 2; suffix: " s" } }
                            SRow { label: qsTr("Postroll"); SSlider { from: 0; to: 10; value: 2; suffix: " s" } }
                            SRow { label: qsTr("Loop by default"); SCheck { checked: false } }
                            SRow { label: qsTr("Scrub audio");     SCheck { checked: true } }
                            SRow { label: qsTr("Arrow key step");  SCombo { model: [qsTr("1 frame"), qsTr("5 frames"), qsTr("10 frames")] } }
                        }
                        Item { height: 20 }
                    }

                    // ── AI ───────────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Groq API Key")
                            ColumnLayout {
                                width: parent.width
                                spacing: 10
                                Label {
                                    text: qsTr("Stored securely in Windows Credential Manager.")
                                    color: theme.colors.textSecondary
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                TextField {
                                    id: apiKeyField
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: 520
                                    implicitHeight: 36
                                    echoMode: showKey.checked ? TextInput.Normal : TextInput.Password
                                    placeholderText: "gsk_…"
                                    color: theme.colors.textPrimary
                                    font.pixelSize: 13
                                    leftPadding: 10
                                    background: Rectangle {
                                        color: theme.colors.elevated
                                        border.color: apiKeyField.activeFocus ? theme.colors.borderFocus : theme.colors.borderColor
                                        radius: 6
                                    }
                                    Component.onCompleted: {
                                        if (mainWindow && mainWindow.hasGroqApiKey)
                                            placeholderText = qsTr("Enter new key to replace saved key…")
                                    }
                                    Connections {
                                        target: mainWindow
                                        function onGroqKeyChanged() {
                                            if (mainWindow && mainWindow.hasGroqApiKey)
                                                apiKeyField.placeholderText = qsTr("Enter new key to replace saved key…")
                                        }
                                    }
                                }
                                RowLayout {
                                    spacing: 10
                                    SCheck { id: showKey; checked: false }
                                    Label { text: qsTr("Show key"); color: theme.colors.textSecondary; font.pixelSize: 11 }
                                    Item { Layout.fillWidth: true }
                                    Button {
                                        text: qsTr("Save key")
                                        implicitHeight: 32
                                        font.pixelSize: 11
                                        background: Rectangle { color: parent.hovered ? theme.colors.accentHover : theme.colors.accent; radius: 4 }
                                        contentItem: Text { text: parent.text; color: "#fff"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: if (mainWindow && apiKeyField.text.length > 0) {
                                            mainWindow.setGroqApiKey(apiKeyField.text)
                                            apiKeyField.clear()
                                        }
                                    }
                                    Button {
                                        id: testGroqBtn
                                        text: qsTr("Test connection")
                                        implicitHeight: 32
                                        font.pixelSize: 11
                                        onClicked: {
                                            if (!mainWindow) return
                                            const r = mainWindow.testGroqConnection()
                                            groqTestLabel.text = r.message
                                            groqTestLabel.color = r.ok ? "#7a8470" : theme.colors.danger
                                        }
                                        background: Rectangle { color: parent.hovered ? theme.colors.secondaryPanel : theme.colors.elevated; border.color: theme.colors.borderColor; radius: 4 }
                                        contentItem: Text { text: parent.text; color: theme.colors.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    }
                                }
                                Label {
                                    id: groqTestLabel
                                    text: ""
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        SGroup { title: qsTr("AI behavior")
                            SRow { label: qsTr("Model"); SCombo { model: ["llama-3.3-70b-versatile", "llama-3.1-8b-instant", "mixtral-8x7b-32768"] } }
                            SRow { label: qsTr("Auto suggestions");     SCheck { checked: true } }
                            SRow { label: qsTr("Confidence threshold"); SSlider { from: 0; to: 1; value: 0.7; stepSize: 0.05; suffix: "" } }
                            SRow { label: qsTr("Caption language"); SCombo { model: [qsTr("Auto"), "English", "Spanish", "French", "German", "Japanese"] } }
                        }
                        Item { height: 20 }
                    }

                    // ── Performance ──────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("GPU & Rendering")
                            SRow { label: qsTr("GPU memory"); SSlider { from: 0.25; to: 1.0; value: 0.75; stepSize: 0.05; suffix: " of VRAM" } }
                            SRow { label: qsTr("CPU threads"); SSlider { from: 1; to: 32; value: 8; stepSize: 1; suffix: "" } }
                            SRow { label: qsTr("RAM cache");  SSlider { from: 1; to: 64; value: 8; suffix: " GB" } }
                            SRow { label: qsTr("Hardware encoder"); SCombo { model: [qsTr("Auto"), "NVENC", "AMD VCE", "Intel QSV", qsTr("Software")] } }
                            SRow { label: qsTr("Background render"); SCheck { checked: true } }
                        }
                        SGroup { title: qsTr("Proxy")
                            SRow { label: qsTr("Auto-generate proxies"); SCheck { checked: false } }
                            SRow { label: qsTr("Proxy resolution"); SCombo { model: [qsTr("Half"), qsTr("Quarter"), qsTr("Eighth")]; currentIndex: 1 } }
                        }
                        Item { height: 20 }
                    }

                    // ── Export ───────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Defaults")
                            SRow { label: qsTr("Format"); SCombo { model: ["H.264 MP4", "H.265 MP4", "ProRes 422", "DNxHR", "GIF"] } }
                            SRow { label: qsTr("Resolution"); SCombo { model: ["3840×2160 (4K)", "1920×1080 (FHD)", "1280×720 (HD)", "Custom…"]; currentIndex: 1 } }
                            SRow { label: qsTr("Parallel jobs"); SSlider { from: 1; to: 8; value: 2; stepSize: 1; suffix: "" } }
                            SRow { label: qsTr("Email on complete"); SCheck { checked: false } }
                        }
                        Item { height: 20 }
                    }

                    // ── Audio ────────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Audio Device")
                            SRow { label: qsTr("Output device"); SCombo { model: [qsTr("System default"), qsTr("No audio output")] } }
                            SRow { label: qsTr("Sample rate");   SCombo { model: ["44100 Hz", "48000 Hz", "96000 Hz"]; currentIndex: 1 } }
                            SRow { label: qsTr("Buffer size");   SCombo { model: ["128", "256", "512", "1024"]; currentIndex: 1 } }
                            SRow { label: qsTr("Monitor volume"); SSlider { from: 0; to: 1; value: 0.8; stepSize: 0.05; suffix: "" } }
                            SRow { label: qsTr("Scrub audio"); SCheck { checked: true } }
                        }
                        Item { height: 20 }
                    }

                    // ── Shortcuts ────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        SGroup { title: qsTr("Keyboard Shortcuts")
                            Label {
                                Layout.fillWidth: true
                                Layout.margins: 12
                                text: qsTr("Click any row then press a new key combo to remap it. Escape to cancel.")
                                color: theme.colors.textSecondary; font.pixelSize: 11; wrapMode: Text.WordWrap
                            }
                        }

                        Repeater {
                            model: [
                                { cat: "Playback",  action: "Play / Pause",          key: "Space" },
                                { cat: "Playback",  action: "Stop",                   key: "K" },
                                { cat: "Playback",  action: "Forward (J/K/L)",        key: "L" },
                                { cat: "Playback",  action: "Rewind (J/K/L)",         key: "J" },
                                { cat: "Playback",  action: "Step back 1 frame",      key: "Left" },
                                { cat: "Playback",  action: "Step forward 1 frame",   key: "Right" },
                                { cat: "Playback",  action: "Go to beginning",        key: "Home" },
                                { cat: "Playback",  action: "Go to end",              key: "End" },
                                { cat: "Playback",  action: "Set in point",           key: "I" },
                                { cat: "Playback",  action: "Set out point",          key: "O" },
                                { cat: "Edit",      action: "Undo",                   key: "Ctrl+Z" },
                                { cat: "Edit",      action: "Redo",                   key: "Ctrl+Shift+Z" },
                                { cat: "Edit",      action: "Cut",                    key: "Ctrl+X" },
                                { cat: "Edit",      action: "Copy",                   key: "Ctrl+C" },
                                { cat: "Edit",      action: "Paste",                  key: "Ctrl+V" },
                                { cat: "Edit",      action: "Delete",                 key: "Del" },
                                { cat: "Edit",      action: "Ripple delete",          key: "Shift+Del" },
                                { cat: "Edit",      action: "Split at playhead",      key: "Ctrl+K" },
                                { cat: "Edit",      action: "Duplicate",              key: "Ctrl+D" },
                                { cat: "Timeline",  action: "Add video track",        key: "Ctrl+Y" },
                                { cat: "Timeline",  action: "Add audio track",        key: "Ctrl+U" },
                                { cat: "Timeline",  action: "Add marker",             key: "M" },
                                { cat: "Timeline",  action: "Next marker",            key: "Shift+M" },
                                { cat: "File",      action: "New project",            key: "Ctrl+N" },
                                { cat: "File",      action: "Open project",           key: "Ctrl+O" },
                                { cat: "File",      action: "Save",                   key: "Ctrl+S" },
                                { cat: "File",      action: "Save As",                key: "Ctrl+Shift+S" },
                                { cat: "File",      action: "Import media",           key: "Ctrl+I" },
                                { cat: "AI",        action: "Open AI agent",          key: "Ctrl+Shift+A" },
                                { cat: "AI",        action: "Quick command",          key: "Ctrl+Shift+Space" },
                                { cat: "AI",        action: "Auto edit",             key: "Alt+A" },
                                { cat: "AI",        action: "Auto color",            key: "Alt+C" },
                                { cat: "AI",        action: "Remove silences",       key: "Alt+S" },
                                { cat: "AI",        action: "Beat sync",             key: "Alt+B" },
                                { cat: "AI",        action: "Generate captions",     key: "Alt+T" }
                            ]
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 32
                                color: sMA.containsMouse ? theme.colors.secondaryPanel : (index % 2 === 0 ? theme.colors.panelBackground : "transparent")
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                                    Label { text: modelData.cat; color: theme.colors.textDisabled; font.pixelSize: 10; Layout.preferredWidth: 70 }
                                    Label { text: modelData.action; color: theme.colors.textPrimary; font.pixelSize: 11; Layout.fillWidth: true }
                                    Rectangle {
                                        height: 20; width: keyLbl.implicitWidth + 12; radius: 4
                                        color: theme.colors.elevated; border.color: theme.colors.borderColor
                                        Label { id: keyLbl; anchors.centerIn: parent; text: modelData.key; color: theme.colors.textPrimary; font.pixelSize: 10; font.family: "Consolas" }
                                    }
                                }
                                MouseArea { id: sMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle; opacity: 0.3 }
                            }
                        }
                        Item { height: 20 }
                    }
                }
            }

            // Footer
            Rectangle {
                Layout.fillWidth: true; height: 48; color: theme.colors.secondaryPanel
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                    Item { Layout.fillWidth: true }
                    Button {
                        text: qsTr("Restore Defaults"); implicitHeight: 32; font.pixelSize: 12
                        background: Rectangle { color: parent.hovered ? theme.colors.elevated : theme.colors.secondaryPanel; border.color: theme.colors.borderColor; radius: 5 }
                        contentItem: Text { text: parent.text; color: theme.colors.textSecondary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: qsTr("Close"); implicitHeight: 32; implicitWidth: 90; font.pixelSize: 12
                        background: Rectangle { color: parent.hovered ? theme.colors.accentHover : theme.colors.accent; radius: 5 }
                        contentItem: Text { text: parent.text; color: "#fff"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: root.close()
                    }
                }
                Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: theme.colors.borderColor }
            }
        }
    }

    // ── Inline sub-components ────────────────────────────────────────────────
    component SGroup: ColumnLayout {
        property string title: ""
        Layout.fillWidth: true; spacing: 0
        default property alias children_: col2.data
        Rectangle {
            Layout.fillWidth: true; height: 28; color: theme.colors.tertiaryPanel
            Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: title; color: theme.colors.textDisabled; font.pixelSize: 10; font.letterSpacing: 1.2 }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
        }
        ColumnLayout { id: col2; Layout.fillWidth: true; spacing: 0 }
    }

    component SRow: RowLayout {
        property string label: ""
        default property alias ctrl: ctrlSlot.data
        Layout.fillWidth: true; height: 40
        Layout.leftMargin: 16; Layout.rightMargin: 16; spacing: 0
        Label { text: label; color: theme.colors.textSecondary; font.pixelSize: 12; Layout.preferredWidth: 190 }
        Item { id: ctrlSlot; Layout.fillWidth: true; height: parent.height }
        Rectangle { Layout.fillWidth: true; height: 1; color: theme.colors.borderSubtle; opacity: 0.4; Layout.alignment: Qt.AlignBottom }
    }

    component SSlider: RowLayout {
        property real from: 0; property real to: 100; property real value: 50; property real stepSize: 1; property string suffix: ""
        spacing: 8
        Slider {
            id: sld; from: parent.from; to: parent.to; value: parent.value; stepSize: parent.stepSize
            implicitWidth: 160; implicitHeight: 20
            background: Rectangle { x: sld.leftPadding; y: sld.topPadding + sld.availableHeight / 2 - height / 2; width: sld.availableWidth; height: 4; radius: 2; color: theme.colors.elevated
                Rectangle { width: sld.visualPosition * parent.width; height: parent.height; radius: 2; color: theme.colors.accent }
            }
            handle: Rectangle { x: sld.leftPadding + sld.visualPosition * (sld.availableWidth - width); y: sld.topPadding + sld.availableHeight / 2 - height / 2; width: 14; height: 14; radius: 7; color: "#fff"; border.color: theme.colors.accent; border.width: 2 }
        }
        Label { text: sld.value.toFixed(stepSize < 1 ? 2 : 0) + suffix; color: theme.colors.textPrimary; font.pixelSize: 11; font.family: "Consolas"; Layout.preferredWidth: 60 }
    }

    component SCombo: ComboBox {
        implicitWidth: 200; implicitHeight: 28; font.pixelSize: 11
        background: Rectangle { color: theme.colors.elevated; border.color: theme.colors.borderColor; radius: 4 }
        contentItem: Text { leftPadding: 8; text: parent.displayText; color: theme.colors.textPrimary; font: parent.font; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
    }

    component SCheck: CheckBox {
        indicator: Rectangle { width: 16; height: 16; radius: 3; x: 0; y: (parent.height - height) / 2; color: parent.checked ? theme.colors.accent : theme.colors.elevated; border.color: parent.checked ? theme.colors.accent : theme.colors.borderColor
            Label { anchors.centerIn: parent; visible: parent.parent.checked; text: "\u2713"; color: "#fff"; font.pixelSize: 10; font.weight: Font.Bold }
        }
        background: Item {}
    }
}
