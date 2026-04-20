import QtQuick
import QtQuick.Shapes

// Vector-drawn tool icons — no fonts, no emoji, no letters.
// kind: select | pen | razor | ripple | rolling | slip | slide | hand | zoom | snap
Shape {
    id: root
    property string kind: "select"
    property color strokeCol: "#9a9a9a"
    property real pixelSize: 16

    width: pixelSize
    height: pixelSize
    antialiasing: true
    layer.enabled: true
    layer.samples: 4

    ShapePath {
        strokeColor: root.strokeCol
        strokeWidth: 1.35
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin

        PathSvg {
            path: {
                switch (root.kind) {
                    case "select":  return "M 3 2 L 3 13 L 6 10 L 8.5 14 L 10 13 L 7.5 9 L 12 9 Z"
                    case "pen":     return "M 3 13 L 6 10 L 12 4 L 13 5 L 13 5 L 7 11 L 4 11 Z"
                    case "razor":   return "M 3 9 L 11 9 L 14 5 M 11 9 L 14 13"
                    case "ripple":  return "M 4 3 L 4 13 M 6 5 L 6 11 M 10 5 L 10 11 M 12 3 L 12 13"
                    case "rolling": return "M 3 5 L 7 8 L 3 11 M 13 5 L 9 8 L 13 11"
                    case "slip":    return "M 2 8 L 14 8 M 3 6 L 5 10 M 11 6 L 13 10"
                    case "slide":   return "M 3 5 L 13 5 M 3 11 L 13 11 M 7 8 L 9 8"
                    case "hand":    return "M 4 8 L 4 13 M 6 5 L 6 13 M 8 3 L 8 13 M 10 5 L 10 13 M 12 8 L 12 13"
                    case "zoom":    return "M 3 7 A 4 4 0 1 1 11 7 A 4 4 0 1 1 3 7 M 10 10 L 13 13"
                    case "snap":    return "M 4 3 L 4 10 A 4 4 0 0 0 12 10 L 12 3 M 4 3 L 6 3 M 10 3 L 12 3"
                    default:        return "M 3 3 L 13 13"
                }
            }
        }
    }
}
