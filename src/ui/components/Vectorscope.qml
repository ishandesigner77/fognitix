import QtQuick

Canvas {
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.fillStyle = "#171717"
        ctx.fillRect(0, 0, width, height)
        ctx.strokeStyle = "#d4c9b0"
        ctx.strokeRect(width * 0.1, height * 0.1, width * 0.8, height * 0.8)
    }
}
