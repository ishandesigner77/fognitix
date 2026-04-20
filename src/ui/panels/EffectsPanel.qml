import QtQuick
import QtQuick.Controls
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme { id: theme }

    EffectStackPanel {
        anchors.fill: parent
        embedded: false
        compact: false
        showHeader: true
        headerTitle: qsTr("Effect Controls")
    }
}
