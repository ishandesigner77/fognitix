import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

    property var filteredMedia: []

    function rebuildFilteredMedia() {
        const pool = mainWindow && mainWindow.mediaPool ? mainWindow.mediaPool : []
        const q = searchField.text.trim().toLowerCase()
        const fi = filterCombo.currentIndex
        const out = []
        for (let i = 0; i < pool.length; i++) {
            const d = pool[i]
            const n = (d.name || "").toLowerCase()
            const isVid = n.endsWith(".mp4") || n.endsWith(".mov") || n.endsWith(".mkv") || n.endsWith(".webm")
            const isAud = n.endsWith(".mp3") || n.endsWith(".wav") || n.endsWith(".aac")
            const isStill = n.endsWith(".png") || n.endsWith(".jpg") || n.endsWith(".jpeg")
                              || n.endsWith(".svg") || n.endsWith(".tiff")
            if (fi === 1 && !isVid)
                continue
            if (fi === 2 && !isAud)
                continue
            if (fi === 3 && !isStill)
                continue
            if (q.length > 0 && !n.includes(q))
                continue
            out.push(d)
        }
        root.filteredMedia = out
    }

    Connections {
        target: mainWindow
        function onMediaPoolChanged() { root.rebuildFilteredMedia() }
    }

    Component.onCompleted: rebuildFilteredMedia()

    function localPathsFromDrop(drop) {
        const out = []
        if (!drop || !drop.urls)
            return out
        for (let i = 0; i < drop.urls.length; i++) {
            const u = drop.urls[i]
            const s = typeof u === "string" ? u : (u && u.toString ? u.toString() : String(u))
            if (s.indexOf("file:///") === 0)
                out.push(decodeURIComponent(s.substring(8)))
            else if (s.indexOf("file://") === 0)
                out.push(decodeURIComponent(s.substring(7).replace(/^\/+/, "")))
        }
        return out
    }

    function formatDuration(sec) {
        if (!sec || sec <= 0) return "--:--"
        const m = Math.floor(sec / 60)
        const s = Math.floor(sec % 60)
        return String(m).padStart(2, "0") + ":" + String(s).padStart(2, "0")
    }

    ListModel {
        id: compModel
        ListElement { name: "Main Sequence";   duration: "00:30"; fps: "30"; res: "1920×1080" }
        ListElement { name: "Intro Comp";      duration: "00:08"; fps: "30"; res: "1920×1080" }
        ListElement { name: "Logo Reveal";     duration: "00:05"; fps: "60"; res: "1920×1080" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Toolbar ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: theme.colors.menuBarBackground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 4
                spacing: 4

                // Import button
                ToolButton {
                    text: "\u2B06 Import"
                    font.pixelSize: 11
                    implicitHeight: 28
                    ToolTip.text: qsTr("Import media files")
                    ToolTip.visible: hovered
                    ToolTip.delay: 400
                    onClicked: if (mainWindow) mainWindow.openImportMediaDialog()
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.elevated : "transparent"
                        border.color: theme.colors.borderColor
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text; font: parent.font
                        color: theme.colors.textSecondary
                        leftPadding: 6; rightPadding: 6
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // New composition
                ToolButton {
                    text: "\u2295 Comp"
                    font.pixelSize: 11
                    implicitHeight: 28
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.elevated : "transparent"
                        border.color: theme.colors.borderColor
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text; font: parent.font
                        color: theme.colors.textSecondary
                        leftPadding: 6; rightPadding: 6
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // View toggle: list / grid
                ToolButton {
                    text: "\u2630"
                    font.pixelSize: 14
                    implicitWidth: 26; implicitHeight: 26
                    background: Rectangle { color: "transparent" }
                    contentItem: Text {
                        text: parent.text; font: parent.font
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderColor
            }
        }

        // ── Search ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: theme.colors.panelBackground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Label {
                    text: "\uD83D\uDD0D"
                    font.pixelSize: 12
                    color: theme.colors.textDisabled
                }

                ComboBox {
                    id: filterCombo
                    Layout.preferredWidth: 108
                    implicitHeight: 32
                    model: [qsTr("All"), qsTr("Video"), qsTr("Audio"), qsTr("Stills")]
                    onActivated: root.rebuildFilteredMedia()
                    background: Rectangle {
                        color: theme.colors.panelElevated
                        border.color: theme.colors.borderHairline
                        radius: 6
                    }
                    contentItem: Text {
                        leftPadding: 8
                        rightPadding: filterCombo.indicator.width + 8
                        text: filterCombo.displayText
                        font.pixelSize: theme.typography.caption
                        font.family: theme.typography.fontFamily
                        color: theme.colors.textPrimary
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                FxTextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search media…")
                    onTextChanged: root.rebuildFilteredMedia()
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: theme.colors.borderSubtle
            }
        }

        // ── Compositions section ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: theme.colors.tertiaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                spacing: 6
                Label {
                    text: theme.icons.expand
                    color: theme.colors.textDisabled
                    font.pixelSize: 9
                }
                Label {
                    text: qsTr("COMPOSITIONS")
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: theme.typography.letterSpacingCaps
                    font.weight: Font.Bold
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: compModel.count
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    rightPadding: 8
                }
            }
        }

        // Composition list
        ListView {
            id: compList
            Layout.fillWidth: true
            height: Math.min(compModel.count * 56, 168)
            model: compModel
            clip: true

            delegate: Rectangle {
                width: compList.width
                height: 56
                color: compMA.containsMouse ? theme.colors.tertiaryPanel : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8
                    spacing: 8

                    Label {
                        text: "\u25A6"
                        color: theme.colors.accent
                        font.pixelSize: 12
                    }
                    Label {
                        Layout.fillWidth: true
                        text: model.name
                        color: theme.colors.textPrimary
                        font.pixelSize: theme.typography.body
                        elide: Text.ElideRight
                    }
                    Label {
                        text: model.fps + "fps"
                        color: theme.colors.textDisabled
                        font.pixelSize: theme.typography.caption
                    }
                    Label {
                        text: model.duration
                        color: theme.colors.textDisabled
                        font.pixelSize: theme.typography.caption
                        font.family: "Consolas"
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1
                    color: theme.colors.borderSubtle
                }

                MouseArea {
                    id: compMA
                    anchors.fill: parent
                    hoverEnabled: true
                    onDoubleClicked: { /* open composition */ }
                }
            }
        }

        // ── Media Pool section ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: theme.colors.tertiaryPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                spacing: 6
                Label {
                    text: theme.icons.expand
                    color: theme.colors.textDisabled
                    font.pixelSize: 9
                }
                Label {
                    text: qsTr("MEDIA POOL")
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: theme.typography.letterSpacingCaps
                    font.weight: Font.Bold
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: mainWindow && mainWindow.mediaPool ? mainWindow.mediaPool.length : 0
                    color: theme.colors.textDisabled
                    font.pixelSize: theme.typography.micro
                    rightPadding: 8
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            GridView {
                id: mediaGrid
                anchors.left: parent.left
                anchors.right: parent.right
                width: parent.width
                implicitHeight: contentHeight > 0 ? contentHeight : 400
                cellWidth: 220
                cellHeight: 58
                model: root.filteredMedia
                clip: true

                delegate: Rectangle {
                    required property var modelData
                    width: mediaGrid.cellWidth - 8
                    height: mediaGrid.cellHeight - 8
                    radius: 6
                    color: cellMA.containsMouse ? theme.colors.tertiaryPanel : theme.colors.secondaryPanel
                    border.color: cellMA.containsMouse ? theme.colors.edgeHighlight : theme.colors.borderSubtle
                    border.width: 1

                    readonly property string mid: modelData.id || ""
                    readonly property string mpath: modelData.path || ""
                    readonly property string mname: modelData.name || ""
                    readonly property real mdur: modelData.duration !== undefined ? modelData.duration : 0
                    readonly property bool isVideo: {
                        const n = (mname || "").toLowerCase()
                        return n.endsWith(".mp4") || n.endsWith(".mov") || n.endsWith(".mkv") || n.endsWith(".webm")
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Item {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                id: thumb
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: isVideo && mid.length > 0
                                source: isVideo && mid.length > 0 ? ("image://fognitixThumb/" + mid + "|0.5|40|40") : ""
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: !thumb.visible
                                radius: 4
                                color: Qt.alpha(theme.colors.trackVideo, 0.25)
                                Label {
                                    anchors.centerIn: parent
                                    text: isVideo ? "\uD83C\uDFA5" : "\u266B"
                                    font.pixelSize: 18
                                    color: theme.colors.textSecondary
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: mname
                                color: theme.colors.textPrimary
                                font.pixelSize: theme.typography.uiLabel
                                font.family: theme.typography.fontFamily
                                elide: Text.ElideRight
                            }

                            Label {
                                text: root.formatDuration(mdur)
                                color: theme.colors.textMuted
                                font.pixelSize: theme.typography.timestamp
                                font.family: "Consolas"
                            }
                        }
                    }

                    MouseArea {
                        id: cellMA
                        anchors.fill: parent
                        hoverEnabled: true
                        onDoubleClicked: {
                            if (mainWindow && mpath.length > 0)
                                mainWindow.importMedia(mpath)
                        }
                    }
                }
            }
        }
    }

    DropArea {
        anchors.fill: parent
        z: 10
        onDropped: function (drop) {
            const paths = root.localPathsFromDrop(drop)
            if (mainWindow && paths.length > 0)
                mainWindow.importMediaPaths(paths)
        }
    }

}
