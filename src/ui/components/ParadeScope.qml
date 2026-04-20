import QtQuick
Row {
    spacing: 2
    Repeater {
        model: 3
        Rectangle {
            width: 80
            height: 120
            color: index === 0 ? "#2a4a8a" : index === 1 ? "#2a6a3a" : "#6a2a4a"
        }
    }
}
