import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Flickable {
    id: root
    signal openScreen(string screen)
    contentWidth: width
    contentHeight: content.height
    clip: true

    ColumnLayout {
        id: content
        width: root.width
        spacing: 20
        anchors.margins: 24

        Label { text: "RGCS"; color: "#eef8ff"; font.pixelSize: 34; font.bold: true; Layout.leftMargin: 24; Layout.topMargin: 24 }
        Label { text: "Logged in as " + appController.auth.username + " (" + appController.auth.role + ")"; color: "#a9c1d6"; Layout.leftMargin: 24 }

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            columns: width > 900 ? 4 : 2
            rowSpacing: 14
            columnSpacing: 14

            Repeater {
                model: ["Fly", "Plan", "Setup", "Settings"]
                delegate: StatusCard {
                    visible: appController.permissions.can(appController.auth.role, "screen." + modelData.toLowerCase())
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    title: modelData
                    value: modelData === "Fly" ? appController.connection.status : "Open"
                    accent: modelData === "Fly" ? "#37d67a" : modelData === "Plan" ? "#1f78d1" : modelData === "Setup" ? "#ffbf47" : "#b28cff"
                    onClicked: root.openScreen(modelData)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            spacing: 12
            ActionButton { text: appController.connection.connected ? "Disconnect" : "Connect SITL UDP"; onClicked: appController.connection.connected ? appController.connection.disconnectLink() : appController.connection.connectLink() }
            Label { text: appController.commands.lastResult; color: "#a9c1d6"; Layout.fillWidth: true }
        }

        Label { text: "Recent audit events"; color: "#e8f3ff"; font.pixelSize: 18; font.bold: true; Layout.leftMargin: 24 }
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            model: appController.audit.recentEvents
            delegate: Label { width: ListView.view.width; text: modelData; color: "#9fb8cc"; elide: Text.ElideRight; padding: 4 }
        }
    }
}
