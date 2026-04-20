import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBg

    Theme { id: theme }

    property real zoomLevel: 1.0
    property bool hasComps: true

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

                Text {
                    text: "FLOWCHART"
                    font.pixelSize: theme.typography.micro
                    font.letterSpacing: 0.6
                    font.weight: Font.Medium
                    color: theme.colors.textMuted
                }

                Item { Layout.fillWidth: true }

                // Zoom controls
                Repeater {
                    model: [
                        { sym: "\u2212", tip: "Zoom Out" },
                        { sym: "+",      tip: "Zoom In" }
                    ]

                    delegate: Rectangle {
                        width: 24; height: 24; radius: 2
                        color: zMa.containsMouse ? theme.colors.surfaceHover : "transparent"
                        border.width: 1; border.color: zMa.containsMouse ? theme.colors.borderSoft : "transparent"

                        Text { anchors.centerIn: parent; text: modelData.sym; font.pixelSize: 12; color: theme.colors.textPrimary }
                        ToolTip.visible: zMa.containsMouse; ToolTip.text: modelData.tip; ToolTip.delay: 600

                        MouseArea {
                            id: zMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.sym === "+") zoomLevel = Math.min(2.0, zoomLevel + 0.1)
                                else zoomLevel = Math.max(0.4, zoomLevel - 0.1)
                            }
                        }
                    }
                }

                Rectangle {
                    width: 24; height: 24; radius: 2
                    color: fitMa.containsMouse ? theme.colors.surfaceHover : "transparent"
                    border.width: 1; border.color: fitMa.containsMouse ? theme.colors.borderSoft : "transparent"

                    Text { anchors.centerIn: parent; text: "\u2922"; font.pixelSize: 13; color: theme.colors.textPrimary }
                    ToolTip.visible: fitMa.containsMouse; ToolTip.text: "Auto Fit"; ToolTip.delay: 600
                    MouseArea { id: fitMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: zoomLevel = 1.0 }
                }
            }
        }

        // Flowchart canvas
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Empty state
            ColumnLayout {
                anchors.centerIn: parent
                visible: !hasComps
                spacing: theme.spacing.sm

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u25A3"
                    font.pixelSize: 32
                    color: theme.colors.textDim
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No compositions"
                    font.pixelSize: theme.typography.small
                    color: theme.colors.textMuted
                }
            }

            // Flowchart drawing canvas
            Canvas {
                id: flowCanvas
                anchors.fill: parent
                visible: hasComps

                property real zoom: zoomLevel

                onZoomChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.fillStyle = "#1e1e1e"
                    ctx.fillRect(0, 0, width, height)

                    var z = zoom
                    var cx = width / 2
                    var cy = height / 2

                    // Dot grid
                    ctx.fillStyle = "#2a2a2a"
                    for (var gx = 0; gx < width; gx += 30 * z) {
                        for (var gy = 0; gy < height; gy += 30 * z) {
                            ctx.beginPath(); ctx.arc(gx, gy, 1, 0, Math.PI * 2); ctx.fill()
                        }
                    }

                    // Define boxes
                    var bw = 130 * z, bh = 46 * z, br = 5 * z
                    var boxes = [
                        { id: "main",    label: "Main Comp",      x: cx - bw/2,          y: 60 * z,        sub: true },
                        { id: "video",   label: "Video Pre-comp", x: cx - bw - 20 * z,   y: 160 * z,       sub: false },
                        { id: "text",    label: "Text Pre-comp",  x: cx + 20 * z,         y: 160 * z,       sub: false },
                        { id: "bg",      label: "Background",     x: cx - bw - 20 * z,   y: 260 * z,       sub: false }
                    ]

                    // Edges
                    var edges = [
                        { from: 0, to: 1 },
                        { from: 0, to: 2 },
                        { from: 1, to: 3 }
                    ]

                    function boxCenterX(b) { return b.x + bw / 2 }
                    function boxCenterY(b) { return b.y + bh / 2 }
                    function boxBottom(b)  { return b.y + bh }
                    function boxTop(b)     { return b.y }

                    // Draw edges first
                    for (var ei = 0; ei < edges.length; ei++) {
                        var e = edges[ei]
                        var bFrom = boxes[e.from], bTo = boxes[e.to]

                        var x1 = boxCenterX(bFrom), y1 = boxBottom(bFrom)
                        var x2 = boxCenterX(bTo),   y2 = boxTop(bTo)

                        ctx.strokeStyle = "#4a4a4a"
                        ctx.lineWidth = 1.5
                        ctx.beginPath()
                        ctx.moveTo(x1, y1)
                        ctx.bezierCurveTo(x1, y1 + 20 * z, x2, y2 - 20 * z, x2, y2)
                        ctx.stroke()

                        // Arrowhead
                        var ax = x2, ay = y2
                        var as2 = 5 * z
                        ctx.fillStyle = "#4a4a4a"
                        ctx.beginPath()
                        ctx.moveTo(ax, ay)
                        ctx.lineTo(ax - as2, ay - as2 * 1.5)
                        ctx.lineTo(ax + as2, ay - as2 * 1.5)
                        ctx.closePath()
                        ctx.fill()
                    }

                    // Draw boxes
                    for (var bi = 0; bi < boxes.length; bi++) {
                        var box = boxes[bi]
                        var bx = box.x, by = box.y

                        // Shadow
                        ctx.shadowColor = "rgba(0,0,0,0.5)"
                        ctx.shadowBlur = 8 * z
                        ctx.shadowOffsetY = 2 * z

                        // Box background
                        ctx.fillStyle = bi === 0 ? "#2d3e52" : "#2d2d2d"
                        roundRect(ctx, bx, by, bw, bh, br)
                        ctx.fill()

                        ctx.shadowBlur = 0; ctx.shadowOffsetY = 0

                        // Border
                        ctx.strokeStyle = bi === 0 ? "#95969a" : "#3d3d3d"
                        ctx.lineWidth = 1
                        roundRect(ctx, bx, by, bw, bh, br)
                        ctx.stroke()

                        // Colored left accent
                        ctx.fillStyle = bi === 0 ? "#95969a" : "#5a5a5a"
                        roundRect(ctx, bx, by, 4 * z, bh, [br, 0, 0, br])
                        ctx.fill()

                        // Label
                        ctx.fillStyle = "#d8d8d8"
                        ctx.font = "bold " + Math.round(11 * z) + "px sans-serif"
                        ctx.textAlign = "left"
                        ctx.fillText(box.label, bx + 12 * z, by + bh * 0.5 + 4 * z)

                        // Small V/A icons
                        ctx.fillStyle = "#5a7a5a"
                        ctx.font = Math.round(8 * z) + "px sans-serif"
                        ctx.fillText("V  A", bx + bw - 28 * z, by + bh * 0.5 + 3 * z)
                    }
                }

                function roundRect(ctx, x, y, w, h, r) {
                    var tl, tr, br2, bl
                    if (typeof r === "number") { tl = tr = br2 = bl = r }
                    else { tl = r[0]; tr = r[1]; br2 = r[2]; bl = r[3] }
                    ctx.beginPath()
                    ctx.moveTo(x + tl, y)
                    ctx.lineTo(x + w - tr, y)
                    ctx.arcTo(x + w, y, x + w, y + tr, tr)
                    ctx.lineTo(x + w, y + h - br2)
                    ctx.arcTo(x + w, y + h, x + w - br2, y + h, br2)
                    ctx.lineTo(x + bl, y + h)
                    ctx.arcTo(x, y + h, x, y + h - bl, bl)
                    ctx.lineTo(x, y + tl)
                    ctx.arcTo(x, y, x + tl, y, tl)
                    ctx.closePath()
                }

                Component.onCompleted: requestPaint()

                Connections {
                    target: root
                    function onZoomLevelChanged() { flowCanvas.requestPaint() }
                }
            }

            // Zoom level badge
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: theme.spacing.sm
                height: 20; width: 48; radius: 2
                color: Qt.rgba(0,0,0,0.5)

                Text {
                    anchors.centerIn: parent
                    text: Math.round(zoomLevel * 100) + "%"
                    font.pixelSize: 10
                    color: theme.colors.textMuted
                }
            }
        }
    }
}
