import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings
import Fognitix

Rectangle {
    id: root
    color: "transparent"

    Theme { id: theme }

    signal closeRequested()

    ListModel { id: aiTabsModel }
    ListModel { id: chatModel }
    property int activeTabIndex: 0
    Settings {
        id: aiSessionSettings
        category: "ai/sessions"
        property string tabsJson: ""
        property int lastTabIndex: 0
    }

    property bool isThinking: mainWindow ? mainWindow.aiBusy : false

    function contextPrefix() {
        if (activeTabIndex < 0 || activeTabIndex >= aiTabsModel.count)
            return ""
        const label = aiTabsModel.get(activeTabIndex).title
        return "[tab:" + label + "] "
    }

    function serializeMessages() {
        const rows = []
        for (let i = 0; i < chatModel.count; i++) {
            const r = chatModel.get(i)
            rows.push({ role: r.role, content: r.content, thinking: r.thinking })
        }
        return JSON.stringify(rows)
    }

    function loadMessages(payload) {
        chatModel.clear()
        if (!payload || payload.length === 0)
            return
        let parsed = []
        try { parsed = JSON.parse(payload) } catch (e) { parsed = [] }
        for (const r of parsed)
            chatModel.append({ role: r.role || "assistant", content: r.content || "", thinking: !!r.thinking })
    }

    function saveActiveTab() {
        if (activeTabIndex < 0 || activeTabIndex >= aiTabsModel.count)
            return
        aiTabsModel.setProperty(activeTabIndex, "messages", serializeMessages())
        persistTabs()
    }

    function persistTabs() {
        const rows = []
        for (let i = 0; i < aiTabsModel.count; i++) {
            const r = aiTabsModel.get(i)
            rows.push({ title: r.title, messages: r.messages || "[]" })
        }
        aiSessionSettings.tabsJson = JSON.stringify(rows)
        aiSessionSettings.lastTabIndex = activeTabIndex
    }

    function switchTab(index) {
        if (index < 0 || index >= aiTabsModel.count || index === activeTabIndex)
            return
        saveActiveTab()
        activeTabIndex = index
        loadMessages(aiTabsModel.get(index).messages)
        Qt.callLater(() => chatView.positionViewAtEnd())
    }

    function newTab() {
        saveActiveTab()
        const title = qsTr("Chat") + " " + String(aiTabsModel.count + 1)
        aiTabsModel.append({ title: title, messages: "[]" })
        activeTabIndex = aiTabsModel.count - 1
        chatModel.clear()
        persistTabs()
    }

    function closeTab(index) {
        if (aiTabsModel.count <= 1 || index < 0 || index >= aiTabsModel.count)
            return
        if (index === activeTabIndex)
            saveActiveTab()
        aiTabsModel.remove(index)
        activeTabIndex = Math.max(0, Math.min(activeTabIndex, aiTabsModel.count - 1))
        loadMessages(aiTabsModel.get(activeTabIndex).messages)
        Qt.callLater(() => chatView.positionViewAtEnd())
        persistTabs()
    }

    Connections {
        target: mainWindow
        function onAiLogAppended(line) {
            chatModel.append({ role: "assistant", content: line, thinking: false })
            chatView.positionViewAtEnd()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: theme.colors.chromePopup
            border.color: theme.colors.chromePopupBorder
            radius: 4

            Row {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                spacing: 4
                Repeater {
                    model: aiTabsModel
                    delegate: Rectangle {
                        required property int index
                        required property string title
                        width: tabText.implicitWidth + 34
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 3
                        color: root.activeTabIndex === index ? theme.colors.accentMuted : "transparent"
                        border.color: root.activeTabIndex === index ? theme.colors.accent : theme.colors.chromePopupBorder
                        border.width: 1
                        Text {
                            id: tabText
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: title
                            font.pixelSize: 10
                            color: root.activeTabIndex === index ? theme.colors.accent : theme.colors.textSecondary
                        }
                        ToolButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            flat: true
                            visible: aiTabsModel.count > 1
                            text: "\u2715"
                            onClicked: root.closeTab(index)
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.switchTab(index)
                        }
                    }
                }
                ToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    height: 22
                    flat: true
                    text: "+"
                    ToolTip.text: qsTr("New AI tab")
                    ToolTip.visible: hovered
                    onClicked: root.newTab()
                }
            }
        }

        ListView {
            id: chatView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            bottomMargin: 6
            topMargin: 4
            model: chatModel

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    color: theme.colors.scrollbar
                    radius: 2
                }
            }

            delegate: Item {
                id: msgItem
                width: chatView.width
                height: bubble.height + 12

                readonly property bool isUser: model.role === "user"

                Rectangle {
                    id: bubble
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.left: msgItem.isUser ? undefined : parent.left
                    anchors.right: msgItem.isUser ? parent.right : undefined
                    anchors.leftMargin: msgItem.isUser ? 0 : 6
                    anchors.rightMargin: msgItem.isUser ? 6 : 0
                    width: Math.min(chatView.width * 0.88, 560)
                    color: msgItem.isUser ? theme.colors.accentMuted : theme.colors.aiBubble
                    border.color: msgItem.isUser ? theme.colors.accent : theme.colors.chromePopupBorder
                    radius: 6
                    height: msgContent.implicitHeight + 16

                    Label {
                        id: msgContent
                        width: parent.width - 16
                        x: 8
                        y: 8
                        text: model.content
                        color: theme.colors.textPrimary
                        font.pixelSize: theme.typography.body
                        font.family: theme.typography.fontFamily
                        wrapMode: Text.WordWrap
                    }
                }
            }

            footer: Item {
                width: chatView.width
                height: root.isThinking ? 36 : 0
                Behavior on height { NumberAnimation { duration: 150 } }

                Rectangle {
                    visible: root.isThinking
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 84
                    height: 26
                    color: theme.colors.aiBubble
                    border.color: theme.colors.borderSubtle
                    radius: 6
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Thinking…")
                        color: theme.colors.aiAccent
                        font.pixelSize: theme.typography.caption
                    }
                }
            }
        }

        Rectangle {
            id: inputArea
            Layout.fillWidth: true
            Layout.preferredHeight: inputCol.implicitHeight + 14
            color: theme.colors.chromePopup
            radius: 4
            border.color: theme.colors.chromePopupBorder
            border.width: 1

            Column {
                id: inputCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                    Rectangle {
                        width: parent.width
                        height: 72
                        color: theme.colors.aiPanelDeep
                        border.color: promptInput.activeFocus ? theme.colors.borderFocus : theme.colors.chromePopupBorder
                        border.width: 1
                        radius: 4

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true

                        TextArea {
                            id: promptInput
                            placeholderText: qsTr("Command…")
                            color: theme.colors.textPrimary
                            placeholderTextColor: theme.colors.textDisabled
                            font.pixelSize: theme.typography.body
                            font.family: theme.typography.fontFamily
                            wrapMode: Text.Wrap
                            background: null
                            padding: 0

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Return && !(event.modifiers & Qt.ShiftModifier)) {
                                    event.accepted = true
                                    sendMessage()
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Label {
                        text: String(promptInput.text.length)
                        color: theme.colors.textDisabled
                        font.pixelSize: theme.typography.micro
                        font.family: "Consolas"
                    }

                    Item { Layout.fillWidth: true }

                    FxButton {
                        text: root.isThinking ? qsTr("Wait") : qsTr("Send")
                        variant: "primary"
                        enabled: !root.isThinking && promptInput.text.trim().length > 0
                        implicitWidth: 88
                        implicitHeight: 30
                        onClicked: sendMessage()
                    }
                }
            }
        }
    }

    function sendMessage() {
        const raw = promptInput.text.trim()
        if (!raw || root.isThinking)
            return

        const msg = contextPrefix() + raw
        chatModel.append({ role: "user", content: raw, thinking: false })
        promptInput.text = ""
        chatView.positionViewAtEnd()

        if (mainWindow) {
            mainWindow.submitAiPrompt(msg)
        } else {
            chatModel.append({
                role: "assistant",
                content: qsTr("No project loaded. Open a project first."),
                thinking: false
            })
        }
        saveActiveTab()
    }

    Component.onCompleted: {
        let rows = []
        try { rows = JSON.parse(aiSessionSettings.tabsJson) } catch (e) { rows = [] }
        if (rows.length > 0) {
            for (const r of rows)
                aiTabsModel.append({ title: r.title || qsTr("Chat"), messages: r.messages || "[]" })
            activeTabIndex = Math.max(0, Math.min(aiSessionSettings.lastTabIndex, aiTabsModel.count - 1))
            loadMessages(aiTabsModel.get(activeTabIndex).messages)
        } else {
            aiTabsModel.append({ title: qsTr("Chat 1"), messages: "[]" })
            chatModel.append({
                role: "assistant",
                content: qsTr("Agent ready."),
                thinking: false
            })
            saveActiveTab()
        }
    }
}
