import QtQuick
import Fognitix

Item {
    id: root
    width: 14

    Theme { id: theme }

    // Flag (top marker)
    Rectangle {
        x: 3
        y: 0
        width: 8
        height: 10
        color: "#c86050"
        radius: 1
    }
    Rectangle {
        x: 3
        y: 10
        width: 8
        height: 3
        color: "#c86050"
        rotation: 0
    }
    // Arrow-point of the flag
    Canvas {
        x: 3
        y: 10
        width: 8
        height: 4
        onPaint: {
            var c = getContext("2d")
            c.reset()
            c.fillStyle = "#c86050"
            c.beginPath()
            c.moveTo(0, 0)
            c.lineTo(8, 0)
            c.lineTo(4, 4)
            c.closePath()
            c.fill()
        }
    }

    // Main line
    Rectangle {
        x: 6
        y: 14
        width: 2
        height: root.height - 14
        color: "#c86050"
    }
}
