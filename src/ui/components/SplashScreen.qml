import QtQuick
import QtQuick.Controls
import Fognitix

Item {
    id: root
    anchors.fill: parent
    z: 9999

    signal finished()

    property real progress: bootProgress ? bootProgress.progress : 0.0
    property string statusText: bootProgress ? bootProgress.statusText : qsTr("Initializing…")
    property bool done: false

    Theme { id: theme }

    readonly property bool bootReady: !bootProgress || bootProgress.ready
    property int _splashStartMs: 0

    readonly property var stages: [
        qsTr("Initializing MediaCore…"),
        qsTr("Loading plug-ins…"),
        qsTr("Reading preferences…"),
        qsTr("Initializing GPU pipeline…"),
        qsTr("Loading effect registry…"),
        qsTr("Initializing AI engine…"),
        qsTr("Starting audio engine…"),
        qsTr("Fognitix ready.")
    ]
    property int _stageIdx: 0
    property string _stageText: stages[0]

    Timer {
        id: stageTimer
        interval: 340
        running: true
        repeat: true
        onTriggered: {
            if (root._stageIdx < root.stages.length - 1) {
                root._stageIdx++
                root._stageText = root.stages[root._stageIdx]
            }
        }
    }

    Timer {
        id: minDisplayTimer
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            const elapsed = Date.now() - root._splashStartMs
            if (root.bootReady && elapsed >= 900) {
                repeat = false
                running = false
                stageTimer.stop()
                root._stageText = root.stages[root.stages.length - 1]
                Qt.callLater(() => fadeOut.start())
            }
        }
    }

    Component.onCompleted: root._splashStartMs = Date.now()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.03, 0.05, 0.72)
    }

    Rectangle {
        id: cardShadow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 2
        anchors.verticalCenterOffset: 6
        width: Math.min(420, parent.width - 48) + 6
        height: Math.min(200, parent.height - 48) + 6
        radius: 14
        color: Qt.rgba(0, 0, 0, 0.4)
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(420, parent.width - 48)
        height: Math.min(200, parent.height - 48)
        radius: 12
        color: theme.colors.panelElevated
        border.color: theme.colors.borderHairline
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Row {
                spacing: 12
                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: theme.colors.accentHover
                        }
                        GradientStop {
                            position: 1.0
                            color: theme.colors.accentActive
                        }
                    }
                    Label {
                        anchors.centerIn: parent
                        text: "Fx"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.weight: Font.Black
                    }
                }
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: "Fognitix"
                        color: theme.colors.textPrimary
                        font.pixelSize: theme.typography.section
                        font.weight: Font.Bold
                        font.family: theme.typography.fontFamily
                    }
                    Label {
                        text: qsTr("AI motion editor")
                        color: theme.colors.textSecondary
                        font.pixelSize: theme.typography.caption
                        font.family: theme.typography.fontFamily
                    }
                }
            }

            Label {
                width: parent.width
                text: root.statusText.length > 0 ? root.statusText : root._stageText
                color: theme.colors.textMuted
                font.pixelSize: theme.typography.caption
                font.family: "Consolas"
                elide: Text.ElideRight
            }

            Rectangle {
                id: barBg
                width: parent.width
                height: 3
                radius: 1.5
                color: theme.colors.primaryBackground
                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: barBg.width * Math.min(1.0, Math.max(0.0,
                        root.progress > 0 ? root.progress
                        : Math.min(0.95, root._stageIdx / Math.max(1, root.stages.length - 1))
                    ))
                    color: theme.colors.accent
                    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                }
            }

            Label {
                width: parent.width
                text: qsTr("© Fognitix")
                color: theme.colors.textDisabled
                font.pixelSize: theme.typography.micro
            }
        }
    }

    NumberAnimation {
        id: fadeOut
        running: false
        target: root
        property: "opacity"
        to: 0
        duration: 380
        easing.type: Easing.InQuad
        onFinished: {
            root.done = true
            root.visible = false
            root.finished()
        }
    }
}
