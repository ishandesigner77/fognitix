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

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: theme.spacing.md
                text: "LUMETRI SCOPES"
                font.pixelSize: theme.typography.micro
                font.letterSpacing: 0.6
                font.weight: Font.Medium
                color: theme.colors.textMuted
            }
        }

        // Tab bar
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ["Vectorscope", "Parade", "Waveform", "Histogram"]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: parent.height
                        color: scopeTabBar.currentIndex === index ? theme.colors.surfaceRaised : (tabMa.containsMouse ? theme.colors.surfaceHover : "transparent")

                        Rectangle {
                            visible: scopeTabBar.currentIndex === index
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 2
                            color: theme.colors.accent
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: theme.typography.small
                            color: scopeTabBar.currentIndex === index ? theme.colors.textPrimary : theme.colors.textMuted
                        }

                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: scopeTabBar.currentIndex = index
                        }
                    }
                }
            }

            QtObject {
                id: scopeTabBar
                property int currentIndex: 0
            }
        }

        // Scope canvas area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: scopeCanvas
                anchors.fill: parent
                anchors.margins: 4

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    var idx = scopeTabBar.currentIndex

                    if (idx === 0) drawVectorscope(ctx)
                    else if (idx === 1) drawParade(ctx)
                    else if (idx === 2) drawWaveform(ctx)
                    else if (idx === 3) drawHistogram(ctx)
                }

                function drawVectorscope(ctx) {
                    var cx = width / 2, cy = height / 2
                    var r = Math.min(width, height) * 0.44

                    // Dark background
                    ctx.fillStyle = "#0d0d0d"
                    ctx.fillRect(0, 0, width, height)

                    // Color wheel ring segments
                    var colors = ["#cc3333","#cc8833","#cccc33","#33cc33","#3333cc","#cc33cc"]
                    for (var i = 0; i < 6; i++) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, (i / 6) * Math.PI * 2, ((i + 1) / 6) * Math.PI * 2)
                        ctx.arc(cx, cy, r * 0.82, ((i + 1) / 6) * Math.PI * 2, (i / 6) * Math.PI * 2, true)
                        ctx.closePath()
                        ctx.fillStyle = colors[i]
                        ctx.globalAlpha = 0.28
                        ctx.fill()
                        ctx.globalAlpha = 1.0
                    }

                    // Inner circle
                    ctx.beginPath()
                    ctx.arc(cx, cy, r * 0.82, 0, Math.PI * 2)
                    ctx.strokeStyle = "#2a2a2a"
                    ctx.lineWidth = 1
                    ctx.stroke()

                    // Outer circle
                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.strokeStyle = "#3a3a3a"
                    ctx.lineWidth = 1
                    ctx.stroke()

                    // Cross hairs
                    ctx.strokeStyle = "#333"
                    ctx.lineWidth = 1
                    ctx.beginPath(); ctx.moveTo(cx - r - 4, cy); ctx.lineTo(cx + r + 4, cy); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(cx, cy - r - 4); ctx.lineTo(cx, cy + r + 4); ctx.stroke()

                    // Skin tone line (~10 o'clock direction)
                    var angle = -2.0
                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.lineTo(cx + Math.cos(angle) * (r + 10), cy + Math.sin(angle) * (r + 10))
                    ctx.strokeStyle = "#996633"
                    ctx.lineWidth = 1
                    ctx.stroke()

                    // Sample dot near skin tone
                    var dotX = cx + Math.cos(angle) * r * 0.35
                    var dotY = cy + Math.sin(angle) * r * 0.35
                    ctx.beginPath()
                    ctx.arc(dotX, dotY, 4, 0, Math.PI * 2)
                    ctx.fillStyle = "#33cc88"
                    ctx.fill()

                    // Labels
                    ctx.fillStyle = "#666"
                    ctx.font = "9px sans-serif"
                    ctx.textAlign = "center"
                    var labels = [["R",1.05],["Yl",0.35],["G",-0.65],["Cy",-1.77],["B",-2.4],["Mg",2.5]]
                    for (var j = 0; j < labels.length; j++) {
                        var la = labels[j][1]
                        ctx.fillText(labels[j][0], cx + Math.cos(la) * (r + 12), cy + Math.sin(la) * (r + 12) + 4)
                    }
                }

                function drawParade(ctx) {
                    ctx.fillStyle = "#0d0d0d"
                    ctx.fillRect(0, 0, width, height)

                    var cols = [{c:"#993333",label:"R"},{c:"#339933",label:"G"},{c:"#333399",label:"B"}]
                    var colW = (width - 8) / 3
                    var padY = 16

                    // Grid lines
                    ctx.strokeStyle = "#1e1e1e"
                    ctx.lineWidth = 1
                    for (var g = 0; g <= 4; g++) {
                        var gy = padY + g * ((height - padY * 2) / 4)
                        ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(width, gy); ctx.stroke()
                        ctx.fillStyle = "#444"
                        ctx.font = "8px monospace"
                        ctx.fillText(Math.round(100 - g * 25), 2, gy + 3)
                    }

                    for (var ci = 0; ci < 3; ci++) {
                        var x0 = 4 + ci * colW + 4
                        var w = colW - 8
                        var col = cols[ci]

                        // Build a rough bar shape
                        ctx.fillStyle = col.c
                        ctx.globalAlpha = 0.6
                        var barH = height - padY * 2

                        // simulate uneven distribution
                        var slices = 20
                        for (var s = 0; s < slices; s++) {
                            var bx = x0 + (s / slices) * w
                            var bw = (w / slices) + 1
                            var nv = 0.4 + 0.5 * Math.sin(s * 0.7 + ci * 1.1) * Math.sin(s * 0.3)
                            if (nv < 0) nv = 0.1
                            var bh = nv * barH
                            ctx.fillRect(bx, padY + (barH - bh), bw, bh)
                        }
                        ctx.globalAlpha = 1.0

                        ctx.fillStyle = col.c
                        ctx.font = "9px sans-serif"
                        ctx.textAlign = "center"
                        ctx.fillText(col.label, x0 + w / 2, height - 4)
                    }
                }

                function drawWaveform(ctx) {
                    ctx.fillStyle = "#0d0d0d"
                    ctx.fillRect(0, 0, width, height)

                    var padY = 14
                    var drawH = height - padY * 2

                    // Grid
                    ctx.strokeStyle = "#1e1e1e"
                    ctx.lineWidth = 1
                    for (var g = 0; g <= 4; g++) {
                        var gy = padY + g * (drawH / 4)
                        ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(width, gy); ctx.stroke()
                        ctx.fillStyle = "#444"
                        ctx.font = "8px monospace"
                        ctx.fillText(Math.round(100 - g * 25), 2, gy + 3)
                    }

                    // Waveform glow
                    ctx.strokeStyle = "#aaaaaa"
                    ctx.lineWidth = 1.5
                    ctx.shadowColor = "#888888"
                    ctx.shadowBlur = 3
                    ctx.beginPath()
                    for (var x = 0; x < width; x++) {
                        var t = x / width
                        var v = 0.5 + 0.22 * Math.sin(t * Math.PI * 6) + 0.1 * Math.sin(t * Math.PI * 17) + 0.08 * Math.cos(t * Math.PI * 3)
                        var y = padY + (1 - v) * drawH
                        if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                    ctx.shadowBlur = 0
                }

                function drawHistogram(ctx) {
                    ctx.fillStyle = "#0d0d0d"
                    ctx.fillRect(0, 0, width, height)

                    var padY = 14, padX = 18
                    var drawW = width - padX
                    var drawH = height - padY * 2

                    // Grid
                    ctx.strokeStyle = "#1e1e1e"
                    ctx.lineWidth = 1
                    for (var g = 0; g <= 4; g++) {
                        var gx = padX + g * (drawW / 4)
                        ctx.beginPath(); ctx.moveTo(gx, padY); ctx.lineTo(gx, padY + drawH); ctx.stroke()
                    }

                    // Bell-curve histogram
                    var bins = 80
                    var peak = drawH * 0.85
                    ctx.fillStyle = "#888888"
                    ctx.globalAlpha = 0.7
                    for (var b = 0; b < bins; b++) {
                        var bx = padX + (b / bins) * drawW
                        var bw = drawW / bins - 1
                        var norm = (b / bins - 0.5) * 3.5
                        var h = peak * Math.exp(-norm * norm * 0.8)
                        // slight secondary bump on highlights
                        h += peak * 0.15 * Math.exp(-((b / bins - 0.82) / 0.06) * ((b / bins - 0.82) / 0.06))
                        ctx.fillRect(bx, padY + drawH - h, bw, h)
                    }
                    ctx.globalAlpha = 1.0

                    // Axis labels
                    ctx.fillStyle = "#444"
                    ctx.font = "8px monospace"
                    ctx.textAlign = "center"
                    ctx.fillText("0", padX, padY + drawH + 10)
                    ctx.fillText("128", padX + drawW / 2, padY + drawH + 10)
                    ctx.fillText("255", padX + drawW, padY + drawH + 10)
                }

                Connections {
                    target: scopeTabBar
                    function onCurrentIndexChanged() { scopeCanvas.requestPaint() }
                }

                Component.onCompleted: requestPaint()
            }
        }

        // Intensity slider
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: theme.colors.surface
            border.width: 1
            border.color: theme.colors.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing.md
                anchors.rightMargin: theme.spacing.md
                spacing: theme.spacing.sm

                Text {
                    text: "Intensity"
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textMuted
                }

                Slider {
                    Layout.fillWidth: true
                    from: 10; to: 100; value: 75
                    height: 24

                    background: Rectangle {
                        x: parent.leftPadding; y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: parent.availableWidth; height: 2
                        color: theme.colors.borderSoft; radius: 1
                        Rectangle { width: parent.parent.visualPosition * parent.width; height: 2; color: theme.colors.accent; radius: 1 }
                    }
                    handle: Rectangle {
                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: 12; height: 12; radius: 6; color: theme.colors.accent
                    }
                }

                Text {
                    text: "75%"
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textPrimary
                    Layout.preferredWidth: 32
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
