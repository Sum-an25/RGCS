import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RGCS

ApplicationWindow {
    id: root
    width: 1366
    height: 768
    minimumWidth: 1100
    minimumHeight: 680
    visible: true
    title: "RGCS"
    color: "#07111f"

    FontLoader { id: inter; source: "" }

    LoginScreen {
        anchors.fill: parent
        visible: !appController.auth.loggedIn
    }

    AppShell {
        anchors.fill: parent
        visible: appController.auth.loggedIn
    }
}
