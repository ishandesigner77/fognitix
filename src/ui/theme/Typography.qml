import QtQuick

QtObject {
    readonly property int timestamp: 9
    readonly property int metadata: 11
    readonly property int uiLabel: 12
    readonly property int button: 13
    readonly property int section: 15
    readonly property int mainHeading: 18

    readonly property int title:    mainHeading
    readonly property int heading:  section
    readonly property int subhead:  uiLabel
    readonly property int body:     metadata
    readonly property int caption:  uiLabel
    readonly property int micro:    timestamp

    readonly property string fontFamily: "Inter, Segoe UI, system-ui, sans-serif"
    readonly property int weightNormal: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightBold:   Font.Bold

    readonly property real letterSpacingCaps: 0.6
}
