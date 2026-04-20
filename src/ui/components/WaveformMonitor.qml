import QtQuick

Canvas {
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.fillStyle = "#0a0a0c"
        ctx.fillRect(0, 0, width, height)
        ctx.strokeStyle = "#7a8470"
        ctx.beginPath()
        ctx.moveTo(0, height / 2)
        for (let x = 0; x < width; x += 4) {
            ctx.lineTo(x, height / 2 + Math.sin(x * 0.05) * (height * 0.35))
        }
        ctx.stroke()
    }
}
