import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground
    Theme { id: theme }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.contentItem: Rectangle { color: theme.colors.scrollbar; radius: 3; implicitWidth: 6 }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 0

            // Clip Info section
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("CLIP INFO")

                InspectorRow { label: qsTr("Name");       value: mainWindow && mainWindow.selectedClipId ? mainWindow.selectedClipId : "—" }
                InspectorRow { label: qsTr("Track");      value: mainWindow && mainWindow.selectedTrackId ? mainWindow.selectedTrackId : "—" }
                InspectorRow { label: qsTr("Duration");   value: "—" }
                InspectorRow { label: qsTr("In Point");   value: appState && appState.hasInPoint ? appState.inPoint.toFixed(3) + " s" : "—" }
                InspectorRow { label: qsTr("Out Point");  value: appState && appState.hasOutPoint ? appState.outPoint.toFixed(3) + " s" : "—" }
                InspectorRow { label: qsTr("Start");      value: "—" }
                InspectorRow { label: qsTr("End");        value: "—" }
            }

            // Video properties section
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("VIDEO")

                InspectorRow { label: qsTr("Resolution"); value: "1920 × 1080" }
                InspectorRow { label: qsTr("Frame Rate"); value: "30 fps" }
                InspectorRow { label: qsTr("Color Space"); value: "Rec. 709" }
                InspectorRow { label: qsTr("Pixel Aspect"); value: "1.0 (square)" }
                InspectorRow { label: qsTr("Field Order"); value: "Progressive" }
                InspectorRow { label: qsTr("Codec");      value: "—" }
                InspectorRow { label: qsTr("Bit Depth");  value: "8-bit" }
            }

            // Audio properties
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("AUDIO")

                InspectorRow { label: qsTr("Sample Rate"); value: "48000 Hz" }
                InspectorRow { label: qsTr("Bit Depth");   value: "16-bit" }
                InspectorRow { label: qsTr("Channels");    value: "Stereo" }
                InspectorRow { label: qsTr("Layout");      value: "L/R" }
            }

            // File info
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("FILE")

                InspectorRow { label: qsTr("File Path");   value: "—"; monoValue: true }
                InspectorRow { label: qsTr("File Size");   value: "—" }
                InspectorRow { label: qsTr("Created");     value: "—" }
                InspectorRow { label: qsTr("Modified");    value: "—" }
            }

            // Timeline / composition
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("COMPOSITION")

                InspectorRow { label: qsTr("Project");     value: mainWindow ? mainWindow.projectName : "—" }
                InspectorRow { label: qsTr("Tracks");      value: mainWindow ? String(mainWindow.trackCount) : "0" }
                InspectorRow { label: qsTr("Clips");       value: mainWindow ? String(mainWindow.clipCount) : "0" }
                InspectorRow { label: qsTr("Duration");    value: mainWindow ? mainWindow.compositionDuration.toFixed(3) + " s" : "—" }
                InspectorRow { label: qsTr("Workspace");   value: mainWindow ? mainWindow.workspace : "—" }
                InspectorRow { label: qsTr("Quality");     value: mainWindow ? mainWindow.previewQuality : "—" }
            }

            // Playback state
            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("PLAYBACK")

                InspectorRow { label: qsTr("Playhead");    value: appState ? appState.playheadSeconds.toFixed(3) + " s" : "—" }
                InspectorRow { label: qsTr("Is Playing");  value: appState ? (appState.isPlaying ? "Yes" : "No") : "—" }
                InspectorRow { label: qsTr("Rate");        value: appState ? appState.playbackRate + "×" : "—" }
                InspectorRow { label: qsTr("Markers");     value: appState ? String(appState.markerCount()) : "0" }
            }

            InspectorSection {
                Layout.fillWidth: true
                title: qsTr("EFFECT STACK")

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 320
                    Layout.minimumHeight: 200
                    EffectStackPanel {
                        anchors.fill: parent
                        embedded: true
                        compact: false
                        showHeader: true
                    }
                }
            }

            Item { height: 12 }
        }
    }

    // ── Sub-components ────────────────────────────────────────────────────────

    component InspectorSection: ColumnLayout {
        property string title: ""
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 26
            color: theme.colors.tertiaryPanel

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 10
                text: title
                color: theme.colors.textDisabled
                font.pixelSize: 9; font.letterSpacing: 1.2
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderColor }
        }
    }

    component InspectorRow: RowLayout {
        property string label: ""
        property string value: ""
        property bool monoValue: false
        Layout.fillWidth: true
        height: 26

        Rectangle {
            Layout.fillWidth: true; height: parent.height
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 8
                Label {
                    text: label + ":"
                    color: theme.colors.textSecondary
                    font.pixelSize: 11
                    Layout.preferredWidth: 96
                }
                Label {
                    text: value
                    color: theme.colors.textPrimary
                    font.pixelSize: 11
                    font.family: monoValue ? "Consolas" : theme.typography.fontFamily
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.colors.borderSubtle; opacity: 0.3 }
        }
    }
}
