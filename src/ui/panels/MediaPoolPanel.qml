import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

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
        if (!sec || sec <= 0)
            return "--:--"
        const m = Math.floor(sec / 60)
        const s = Math.floor(sec % 60)
        return String(m).padStart(2, "0") + ":" + String(s).padStart(2, "0")
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: theme.colors.menuBarBackground
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8
                ToolButton {
                    text: theme.icons.import_ + "  " + qsTr("Import")
                    font.pixelSize: 11
                    implicitHeight: 30
                    onClicked: if (mainWindow) mainWindow.openImportMediaDialog()
                    background: Rectangle {
                        color: parent.hovered ? theme.colors.elevated : "transparent"
                        border.color: theme.colors.borderColor
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: theme.colors.textSecondary
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: mainWindow && mainWindow.mediaPool ? mainWindow.mediaPool.length : 0
                    color: theme.colors.textDisabled
                    font.pixelSize: 10
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderSubtle
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: sc
                anchors.fill: parent
                clip: true
                visible: mainWindow && mainWindow.mediaPool && mainWindow.mediaPool.length > 0
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                GridView {
                    id: grid
                    width: Math.max(100, sc.width - 8)
                    implicitHeight: Math.max(200, contentHeight)
                    cellWidth: 148
                    cellHeight: 96
                    model: mainWindow ? mainWindow.mediaPool : []
                    clip: true

                    delegate: Rectangle {
                        required property var modelData
                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                    radius: 6
                    color: ma.containsMouse ? theme.colors.tertiaryPanel : theme.colors.secondaryPanel
                    border.color: ma.containsMouse ? theme.colors.edgeHighlight : theme.colors.borderSubtle
                    border.width: 1

                    readonly property string mid: modelData.id || ""
                    readonly property string mpath: modelData.path || ""
                    readonly property string mname: modelData.name || ""
                    readonly property real mdur: modelData.duration !== undefined ? modelData.duration : 0
                    readonly property bool isVideo: {
                        const n = (mname || "").toLowerCase()
                        return n.endsWith(".mp4") || n.endsWith(".mov") || n.endsWith(".mkv")
                               || n.endsWith(".webm") || n.endsWith(".avi") || n.endsWith(".wmv") || n.endsWith(".mxf")
                    }

                    Image {
                        id: thumb
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 4
                        height: parent.height - 28
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: isVideo && mid.length > 0
                        source: visible ? ("image://fognitixThumb/" + mid + "|0.5|140|72") : ""
                    }

                    Rectangle {
                        anchors.fill: thumb
                        visible: !thumb.visible
                        radius: 4
                        color: Qt.alpha(theme.colors.trackVideo, 0.2)
                        Label {
                            anchors.centerIn: parent
                            text: isVideo ? qsTr("Video") : qsTr("Audio")
                            font.pixelSize: 10
                            font.family: theme.typography.fontFamily
                            color: theme.colors.textMuted
                        }
                    }

                    Label {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 4
                        text: mname
                        elide: Text.ElideMiddle
                        font.pixelSize: 10
                        color: theme.colors.textPrimary
                    }

                    Label {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 6
                        text: root.formatDuration(mdur)
                        font.pixelSize: 9
                        font.family: "Consolas"
                        color: theme.colors.textDisabled
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onDoubleClicked: if (mainWindow && mpath.length > 0)
                            mainWindow.importMedia(mpath)
                    }
                    }
                }
            }

            Rectangle {
                visible: !mainWindow || !mainWindow.mediaPool || mainWindow.mediaPool.length === 0
                anchors.fill: parent
                color: "transparent"
                border.color: theme.colors.borderSubtle
                border.width: 1
                radius: 8
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uD83D\uDCF9"
                        font.pixelSize: 28
                        color: theme.colors.textDisabled
                    }
                    Label {
                        text: qsTr("Drop media here or click Import")
                        color: theme.colors.textSecondary
                        font.pixelSize: 11
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
