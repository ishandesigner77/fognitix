import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Fognitix

Rectangle {
    id: root
    Theme { id: theme }

    color: theme.colors.panel
    border.color: theme.colors.borderHairline

    // Default off so the program monitor dominates; use overlay "Show scopes" to enable.
    property bool scopesVisible: false
    property bool safeMarginsVisible: false
    property bool abCompareMode: false
    property bool controlsHovered: videoHover.containsMouse || stripHover.containsMouse

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: scopesVisible ? 112 : 0
            Layout.fillHeight: true
            visible: scopesVisible
            color: theme.colors.scopeBackground
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: theme.spacing.s2
                spacing: theme.spacing.s2

                Label {
                    text: qsTr("Scopes")
                    font.pixelSize: theme.typography.micro
                    color: theme.colors.textDisabled
                    font.letterSpacing: 1
                }
                Histogram {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                }
                WaveformMonitor {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                }
                Vectorscope {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                }
            }
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: theme.colors.borderSubtle
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: theme.spacing.s2
                radius: 6
                color: theme.colors.viewerBlack
                border.color: theme.colors.borderHairline
                border.width: 1

                Item {
                    id: monitor
                    anchors.fill: parent
                    anchors.margins: 1

                    Image {
                        id: previewImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        source: appState ? appState.previewImageSource : ""
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: !appState || appState.previewImageSource === ""
                        text: qsTr("No frame — import media or scrub the playhead")
                        color: theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: parent.width - 32
                        font.pixelSize: theme.typography.caption
                        font.family: theme.typography.fontFamily
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.9
                        height: parent.height * 0.9
                        color: "transparent"
                        border.width: 1
                        border.color: "#40ffffff"
                        visible: safeMarginsVisible
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        color: "transparent"
                        border.width: 1
                        border.color: "#25f59e0b"
                        visible: safeMarginsVisible
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: abCompareMode
                        color: "#40000000"
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: theme.spacing.s2
                            text: qsTr("A/B compare (preview)")
                            color: theme.colors.textDisabled
                            font.pixelSize: theme.typography.micro
                        }
                    }

                    Rectangle {
                        id: bottomOverlay
                        z: root.controlsHovered ? 40 : 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 48
                        opacity: root.controlsHovered ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        color: Qt.rgba(0, 0, 0, 0.72)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: theme.spacing.s3
                            anchors.rightMargin: theme.spacing.s3
                            spacing: theme.spacing.s2

                            Button {
                                text: scopesVisible ? qsTr("Hide scopes") : qsTr("Show scopes")
                                flat: true
                                font.pixelSize: theme.typography.caption
                                onClicked: scopesVisible = !scopesVisible
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: theme.colors.textSecondary
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Button {
                                text: qsTr("Safe zones")
                                flat: true
                                checkable: true
                                checked: safeMarginsVisible
                                font.pixelSize: theme.typography.caption
                                onClicked: safeMarginsVisible = !safeMarginsVisible
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: parent.checked ? theme.colors.accent : theme.colors.textSecondary
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Button {
                                text: qsTr("A/B")
                                flat: true
                                checkable: true
                                checked: abCompareMode
                                font.pixelSize: theme.typography.caption
                                onClicked: abCompareMode = !abCompareMode
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: parent.checked ? theme.colors.accent : theme.colors.textSecondary
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: {
                                    if (!appState) return "00:00:00:00"
                                    const s = appState.playheadSeconds
                                    const h = Math.floor(s / 3600)
                                    const m = Math.floor((s % 3600) / 60)
                                    const ss = Math.floor(s % 60)
                                    const fr = Math.floor((s % 1) * 30)
                                    return [h, m, ss, fr].map(v => String(v).padStart(2, "0")).slice(0, 3).join(":")
                                           + ":" + String(fr).padStart(2, "0")
                                }
                                color: theme.colors.accent
                                font.pixelSize: theme.typography.metadata
                                font.family: "Consolas"
                                font.weight: Font.Medium
                            }

                            Button {
                                text: qsTr("Open video…")
                                flat: true
                                font.pixelSize: theme.typography.caption
                                onClicked: openClipDialog.open()
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: theme.colors.textSecondary
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            width: parent.width
                            height: 1
                            color: theme.colors.borderSubtle
                        }
                    }

                    MouseArea {
                        id: videoHover
                        z: 20
                        anchors.fill: parent
                        anchors.bottomMargin: 48
                        hoverEnabled: true
                    }

                    MouseArea {
                        id: stripHover
                        z: 21
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 48
                        hoverEnabled: true
                    }
                }
            }
        }
    }

    FileDialog {
        id: openClipDialog
        title: qsTr("Open video")
        nameFilters: [qsTr("Video (*.mp4 *.mov *.mkv *.webm)"), qsTr("All files (*)")]
        onAccepted: {
            if (mainWindow && openClipDialog.selectedFile.isValid())
                mainWindow.importMedia(openClipDialog.selectedFile.toLocalFile())
        }
    }
}
