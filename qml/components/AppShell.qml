import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../screens"

Item {
    id: shell
    property string currentScreen: "Home"

    Rectangle {
        anchors.fill: parent
        color: "#07111f"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            currentScreen: shell.currentScreen
            onNavigate: screen => shell.currentScreen = screen
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TopStatusBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
            }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: {
                    if (shell.currentScreen === "Fly") return flyScreen
                    if (shell.currentScreen === "Plan") return planScreen
                    if (shell.currentScreen === "Setup") return setupScreen
                    if (shell.currentScreen === "Settings") return settingsScreen
                    return homeScreen
                }
            }
        }
    }

    Component { id: homeScreen; HomeScreen { onOpenScreen: screen => shell.currentScreen = screen } }
    Component { id: flyScreen; FlyScreen {} }
    Component { id: planScreen; PlanScreen {} }
    Component { id: setupScreen; SetupScreen {} }
    Component { id: settingsScreen; SettingsScreen {} }
}
