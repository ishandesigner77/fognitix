import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Item {
    id: root

    Theme { id: theme }

    property ListModel panelsModel: null
    property int currentPanelId: -1
    property var panelMenuItems: []
    property var isPanelActiveFn: null
    property var onSelectPanelFn: null
    property var onClosePanelFn: null
    property var onMovePanelFn: null
    property var onFloatPanelFn: null
    property var onAddPanelFn: null
    property string emptyText: qsTr("No panel open")

    function _panelActive(panelId) {
        if (typeof isPanelActiveFn === "function")
            return !!isPanelActiveFn(panelId)
        return false
    }

    function _call(cb, a, b) {
        if (typeof cb === "function")
            cb(a, b)
    }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.panelBg
        border.color: theme.colors.borderSubtle
        border.width: 1
    }

    Rectangle {
        id: tabBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 34
        color: theme.colors.surfaceRaised

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: theme.colors.borderSubtle
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Flickable {
                    anchors.fill: parent
                    contentWidth: tabsRow.implicitWidth
                    flickableDirection: Flickable.HorizontalFlick
                    clip: true

                    Row {
                        id: tabsRow
                        height: parent.height
                        spacing: 0

                        Repeater {
                            model: root.panelsModel

                            delegate: Item {
                                required property int index
                                required property int panelId
                                required property string panelName
                                property real dragStartX: 0

                                width: Math.max(86, titleLabel.implicitWidth + 30)
                                height: tabBar.height
                                readonly property bool selected: root.currentPanelId === panelId

                                HoverHandler { id: tabHover }

                                Rectangle {
                                    anchors.fill: parent
                                    color: parent.selected ? theme.colors.panelBg
                                        : (tabHover.hovered ? theme.colors.surfaceHigh : "transparent")
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 2
                                    color: theme.colors.accent
                                    opacity: parent.selected ? 0.9 : 0
                                }

                                Text {
                                    id: titleLabel
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.right: closeBtn.left
                                    anchors.rightMargin: 6
                                    text: panelName
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    color: parent.selected ? theme.colors.textPrimary : theme.colors.textMuted
                                }

                                ToolButton {
                                    id: closeBtn
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 16
                                    height: 16
                                    text: "\u2715"
                                    visible: tabHover.hovered
                                    onClicked: root._call(root.onClosePanelFn, panelId)
                                    background: Rectangle {
                                        color: parent.hovered ? theme.colors.surfaceHigh : "transparent"
                                        radius: 2
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: theme.colors.textSecondary
                                        font.pixelSize: 8
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onPressed: (mouse) => {
                                        if (mouse.button === Qt.LeftButton)
                                            parent.dragStartX = mouse.x
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (!(pressedButtons & Qt.LeftButton))
                                            return
                                        const dx = mouse.x - parent.dragStartX
                                        if (dx > width * 0.7)
                                            root._call(root.onMovePanelFn, index, index + 1)
                                        else if (dx < -width * 0.7)
                                            root._call(root.onMovePanelFn, index, index - 1)
                                    }
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton)
                                            root._call(root.onSelectPanelFn, panelId)
                                        else
                                            tabMenu.popup()
                                    }
                                }

                                Menu {
                                    id: tabMenu
                                    MenuItem {
                                        text: qsTr("Move Left")
                                        enabled: index > 0
                                        onTriggered: root._call(root.onMovePanelFn, index, index - 1)
                                    }
                                    MenuItem {
                                        text: qsTr("Move Right")
                                        enabled: root.panelsModel && index < root.panelsModel.count - 1
                                        onTriggered: root._call(root.onMovePanelFn, index, index + 1)
                                    }
                                    MenuSeparator {}
                                    MenuItem {
                                        text: qsTr("Float Panel")
                                        onTriggered: root._call(root.onFloatPanelFn, panelId)
                                    }
                                    MenuItem {
                                        text: qsTr("Close Panel")
                                        onTriggered: root._call(root.onClosePanelFn, panelId)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ToolButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 34
                text: "+"
                onClicked: addPanelPopup.open()
                background: Rectangle {
                    color: parent.hovered ? theme.colors.surfaceHigh : "transparent"
                }
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: theme.colors.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        visible: !root.panelsModel || root.panelsModel.count === 0
        color: theme.colors.panelBg

        Column {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: root.emptyText
                color: theme.colors.textDisabled
                font.pixelSize: 11
            }
            ToolButton {
                text: qsTr("+ Add Panel")
                onClicked: addPanelPopup.open()
            }
        }
    }

    Popup {
        id: addPanelPopup
        y: tabBar.height
        width: 250
        height: Math.min(520, panelList.contentHeight + 4)
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: theme.colors.surfaceRaised
            border.color: theme.colors.borderColor
            border.width: 1
            radius: 5
        }

        ListView {
            id: panelList
            anchors.fill: parent
            clip: true
            model: root.panelMenuItems
            delegate: Item {
                required property var modelData
                width: panelList.width
                height: modelData.type === "header" ? 24 : 28

                Rectangle {
                    anchors.fill: parent
                    color: modelData.type === "header" ? theme.colors.panelAlt : "transparent"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: modelData.type === "header" ? modelData.text.toUpperCase()
                                                      : modelData.name
                    color: modelData.type === "header"
                        ? theme.colors.textDisabled
                        : (root._panelActive(modelData.id) ? theme.colors.textPrimary : theme.colors.textSecondary)
                    font.pixelSize: modelData.type === "header" ? 9 : 11
                    font.bold: modelData.type === "header"
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: modelData.type !== "header"
                    onClicked: {
                        addPanelPopup.close()
                        root._call(root.onAddPanelFn, modelData.id)
                    }
                }
            }
        }
    }
}
