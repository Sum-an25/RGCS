import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string currentScreen: "Home"
    signal navigate(string screen)

    color: "#081827"
    border.color: "#18354f"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Label {
            text: "RGCS"
            color: "#e8f3ff"
            font.pixelSize: 26
            font.bold: true
            Layout.bottomMargin: 12
        }

        Repeater {
            model: appController.permissions.visibleScreens(appController.auth.role)
            delegate: SidebarButton {
                Layout.fillWidth: true
                text: modelData
                iconText: modelData === "Home" ? "H" : modelData === "Fly" ? "F" : modelData === "Plan" ? "P" : modelData === "Setup" ? "S" : modelData === "Settings" ? "G" : "L"
                active: root.currentScreen === modelData
                onClicked: root.navigate(modelData)
            }
        }

        Item { Layout.fillHeight: true }

        Button {
            text: "Logout"
            Layout.fillWidth: true
            onClicked: appController.auth.logout()
        }
    }
}
