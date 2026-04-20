import QtQuick
import Fognitix

Row {
    Theme { id: theme }
    spacing: 2
    Repeater {
        model: 3
        Rectangle {
            width: 80
            height: 120
            color: index === 0 ? theme.colors.clipVideoBg : index === 1 ? theme.colors.clipAudioBg : theme.colors.clipTextBg
        }
    }
}
