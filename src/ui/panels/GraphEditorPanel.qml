import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surfaceRaised
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.md
                anchors.rightMargin: theme.spacing.sm
                spacing: theme.spacing.sm

                Text {
                    text: "GRAPH EDITOR"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                }
                Item { Layout.fillWidth: true }
            }
        }

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.sm
                anchors.rightMargin: theme.spacing.sm
                spacing: theme.spacing.sm

                ComboBox {
                    implicitWidth: 120
                    model: ["Value", "Speed", "Influence"]
                    font.pixelSize: theme.typography.small
                    background: Rectangle { color: theme.colors.surfaceRaised; border.width: 1; border.color: theme.colors.borderSoft; radius: 2 }
                    contentItem: Text { leftPadding: 8; text: parent.displayText; font: parent.font; color: theme.colors.textPrimary; verticalAlignment: Text.AlignVCenter }
                }

                Rectangle { width: 1; height: 18; color: theme.colors.borderSoft }

                Repeater {
                    model: [
                        { sym: "\u2B1A", tip: "Fit to View" },
                        { sym: "\u21F1", tip: "Fit Selected" }
                    ]

                    delegate: Rectangle {
                        width: 26; height: 24; radius: 2
                        color: tbMa.containsMouse ? theme.colors.surfaceHover : "transparent"
                        border.width: 1; border.color: tbMa.containsMouse ? theme.colors.borderSoft : "transparent"

                        Text { anchors.centerIn: parent; text: modelData.sym; font.pixelSize: 12; color: theme.colors.textMuted }
                        ToolTip.visible: tbMa.containsMouse; ToolTip.text: modelData.tip; ToolTip.delay: 600
                        MouseArea { id: tbMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
                }

                Rectangle { width: 1; height: 18; color: theme.colors.borderSoft }

                // Toggle buttons
                Repeater {
                    model: [
                        { label: "Ref", tip: "Show Reference Graph" },
                        { label: "Wfm", tip: "Show Audio Waveform" },
                        { label: "Snap", tip: "Snap" }
                    ]

                    delegate: Rectangle {
                        property bool toggled: false
                        implicitWidth: tglLabel.implicitWidth + 12; height: 22; radius: 2
                        color: toggled ? theme.colors.accent : (tglMa.containsMouse ? theme.colors.surfaceHover : "transparent")
                        border.width: 1; border.color: toggled ? theme.colors.accent : theme.colors.borderSoft

                        Text {
                            id: tglLabel
                            anchors.centerIn: parent
                            text: modelData.label; font.pixelSize: theme.typography.small
                            color: toggled ? theme.colors.textOnAccent : theme.colors.textPrimary
                        }
                        ToolTip.visible: tglMa.containsMouse; ToolTip.text: modelData.tip; ToolTip.delay: 600
                        MouseArea { id: tglMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.toggled = !parent.toggled }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Main graph area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Y-axis labels
            Column {
                id: yAxis
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: xAxisBar.top
                width: 30
                spacing: 0

                Repeater {
                    model: ["100", "75", "50", "25", "0", "-25"]

                    delegate: Item {
                        width: parent.width
                        height: (yAxis.height - 0) / 6

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            font.pixelSize: 9
                            color: theme.colors.textDim
                        }
                    }
                }
            }

            // Canvas
            Canvas {
                id: graphCanvas
                anchors.left: yAxis.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: xAxisBar.top

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    // Background
                    ctx.fillStyle = "#1a1a1a"
                    ctx.fillRect(0, 0, width, height)

                    var gw = width, gh = height
                    var gridStep = 50

                    // Grid lines
                    ctx.strokeStyle = "#282828"
                    ctx.lineWidth = 1
                    for (var x = 0; x < gw; x += gridStep) {
                        ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, gh); ctx.stroke()
                    }
                    for (var y = 0; y < gh; y += gridStep) {
                        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(gw, y); ctx.stroke()
                    }

                    // Zero line
                    var zeroY = gh * 0.5
                    ctx.strokeStyle = "#3a3a3a"
                    ctx.lineWidth = 1.5
                    ctx.beginPath(); ctx.moveTo(0, zeroY); ctx.lineTo(gw, zeroY); ctx.stroke()

                    // Bezier curve in accent color
                    // Control points
                    var p0 = {x: 20,      y: gh * 0.7}
                    var cp1 = {x: gw * 0.25, y: gh * 0.65}
                    var cp2 = {x: gw * 0.55, y: gh * 0.1}
                    var p3 = {x: gw - 20, y: gh * 0.35}

                    ctx.strokeStyle = "#d4c9b0"
                    ctx.lineWidth = 2
                    ctx.shadowColor = "#d4c9b0"
                    ctx.shadowBlur = 4
                    ctx.beginPath()
                    ctx.moveTo(p0.x, p0.y)
                    ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, p3.x, p3.y)
                    ctx.stroke()
                    ctx.shadowBlur = 0

                    // Key point circles
                    ctx.fillStyle = "#d4c9b0"
                    ctx.beginPath(); ctx.arc(p0.x, p0.y, 4, 0, Math.PI*2); ctx.fill()
                    ctx.beginPath(); ctx.arc(p3.x, p3.y, 4, 0, Math.PI*2); ctx.fill()

                    // Control handles as diamonds
                    function drawDiamond(cx, cy, r) {
                        ctx.beginPath()
                        ctx.moveTo(cx, cy - r)
                        ctx.lineTo(cx + r, cy)
                        ctx.lineTo(cx, cy + r)
                        ctx.lineTo(cx - r, cy)
                        ctx.closePath()
                    }

                    // Handle lines
                    ctx.strokeStyle = "#888888"
                    ctx.lineWidth = 1
                    ctx.setLineDash([2, 2])
                    ctx.beginPath(); ctx.moveTo(p0.x, p0.y); ctx.lineTo(cp1.x, cp1.y); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(p3.x, p3.y); ctx.lineTo(cp2.x, cp2.y); ctx.stroke()
                    ctx.setLineDash([])

                    // Diamonds
                    ctx.fillStyle = "#aaaaaa"
                    ctx.strokeStyle = "#555555"
                    ctx.lineWidth = 1
                    drawDiamond(cp1.x, cp1.y, 5); ctx.fill(); ctx.stroke()
                    drawDiamond(cp2.x, cp2.y, 5); ctx.fill(); ctx.stroke()
                }

                Component.onCompleted: requestPaint()
            }

            // X-axis bar
            Rectangle {
                id: xAxisBar
                anchors.left: yAxis.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 20
                color: theme.colors.panelAlt
                border.width: 1; border.color: theme.colors.borderSoft

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 4

                    Repeater {
                        model: ["0", "1s", "2s", "3s", "4s", "5s", "6s"]
                        delegate: Item {
                            width: (xAxisBar.width - 4) / 7
                            height: parent.height

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                font.pixelSize: 9
                                color: theme.colors.textDim
                            }
                        }
                    }
                }
            }
        }
    }
}
