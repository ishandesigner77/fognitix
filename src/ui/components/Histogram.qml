import QtQuick

Canvas {
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.fillStyle = "#0a0a0c"
        ctx.fillRect(0, 0, width, height)
        ctx.fillStyle = "#95969a"
        for (let i = 0; i < 32; ++i) {
            const h = (i * 17) % (height - 4)
            ctx.fillRect(i * (width / 32), height - h, (width / 32) - 2, h)
        }
    }
}
