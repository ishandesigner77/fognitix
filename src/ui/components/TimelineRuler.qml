import QtQuick
import Fognitix

Item {
    id: root

    property real zoomLevel:     1.0   // pixels per second
    property real pixelsPerSec:  80.0
    property real viewOffset:    0.0   // scroll offset in seconds
    property real duration:      30.0  // total composition duration

    Theme { id: theme }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.timelineRuler

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: theme.colors.borderColor
        }

        Canvas {
            id: canvas
            anchors.fill: parent

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()

            Connections {
                target: root
                function onZoomLevelChanged()   { canvas.requestPaint() }
                function onViewOffsetChanged()  { canvas.requestPaint() }
                function onPixelsPerSecChanged() { canvas.requestPaint() }
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                const pps       = root.pixelsPerSec * root.zoomLevel
                const offset    = root.viewOffset
                const fps       = 30
                const spf       = 1.0 / fps

                // Choose tick interval based on zoom
                let majStep, minStep, labelEvery
                if (pps >= 200) {
                    majStep = 1; minStep = spf; labelEvery = 1
                } else if (pps >= 80) {
                    majStep = 1; minStep = 0.5; labelEvery = 1
                } else if (pps >= 30) {
                    majStep = 5; minStep = 1; labelEvery = 5
                } else if (pps >= 10) {
                    majStep = 10; minStep = 5; labelEvery = 10
                } else {
                    majStep = 30; minStep = 10; labelEvery = 30
                }

                // Minor ticks
                ctx.strokeStyle = "#2c2c38"
                ctx.lineWidth = 1
                let t = Math.floor(offset / minStep) * minStep
                while (t <= offset + width / pps + minStep) {
                    const x = Math.round((t - offset) * pps) + 0.5
                    ctx.beginPath()
                    ctx.moveTo(x, height)
                    ctx.lineTo(x, height * 0.6)
                    ctx.stroke()
                    t += minStep
                }

                // Major ticks + labels
                ctx.strokeStyle = "#3a3a48"
                ctx.lineWidth = 1
                ctx.fillStyle = "#7a7a92"
                ctx.font = "10px Consolas"
                ctx.textBaseline = "top"

                t = Math.floor(offset / majStep) * majStep
                while (t <= offset + width / pps + majStep) {
                    const x = Math.round((t - offset) * pps) + 0.5
                    ctx.beginPath()
                    ctx.moveTo(x, height)
                    ctx.lineTo(x, 0)
                    ctx.stroke()

                    if (t % labelEvery < 0.001) {
                        // Format: HH:MM:SS:FF
                        const h  = Math.floor(t / 3600)
                        const m  = Math.floor((t % 3600) / 60)
                        const s  = Math.floor(t % 60)
                        const fr = Math.round((t % 1) * fps)
                        let label
                        if (pps < 20) {
                            label = String(Math.round(t)) + "s"
                        } else if (h > 0) {
                            label = `${String(h).padStart(2,"0")}:${String(m).padStart(2,"0")}:${String(s).padStart(2,"0")}`
                        } else if (m > 0) {
                            label = `${String(m).padStart(2,"0")}:${String(s).padStart(2,"0")}:${String(fr).padStart(2,"0")}`
                        } else {
                            label = `${String(s).padStart(2,"0")}:${String(fr).padStart(2,"0")}`
                        }
                        if (x + 4 < width) {
                            ctx.fillText(label, x + 3, 3)
                        }
                    }
                    t += majStep
                }
            }
        }

        // Playhead marker on ruler
        Rectangle {
            id: playheadMark
            x: appState ? (appState.playheadSeconds - root.viewOffset) * root.pixelsPerSec * root.zoomLevel - 1 : -2
            y: 0
            width: 2
            height: parent.height
            color: theme.colors.playhead
            visible: x >= 0 && x <= parent.width

            Rectangle {
                width: 10
                height: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                color: theme.colors.playheadHead
                radius: 2
                rotation: 45
                y: -3
            }
        }

        // Ruler scrub interaction
        MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => {
                const t = root.viewOffset + mouse.x / (root.pixelsPerSec * root.zoomLevel)
                if (appState) appState.playheadSeconds = Math.max(0, t)
            }
            onPositionChanged: (mouse) => {
                if (pressed) {
                    const t = root.viewOffset + mouse.x / (root.pixelsPerSec * root.zoomLevel)
                    if (appState) appState.playheadSeconds = Math.max(0, t)
                }
            }
        }
    }
}
