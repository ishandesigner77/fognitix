import QtQuick

QtObject {
    id: themeRoot

    readonly property string palette: (typeof mainWindow !== "undefined" && mainWindow)
                                      ? mainWindow.uiPalette : "dark"

    property QtObject darkColors: Colors {}
    property QtObject lightColors: ColorsLight {}
    readonly property QtObject colors: palette === "light" ? lightColors : darkColors
    property QtObject typography: Typography {}
    property QtObject spacing: Spacing {}
    property QtObject icons: Icons {}
    property QtObject animations: Animations {}
}
