import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    color: "#07111f"

    Rectangle {
        width: 420
        height: 420
        anchors.centerIn: parent
        radius: 8
        color: "#0b1b2c"
        border.color: "#24415d"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 14

            Label { text: "RGCS"; color: "#eef8ff"; font.pixelSize: 36; font.bold: true; Layout.fillWidth: true }
            Label { text: "Secure ground control login"; color: "#9fb8cc"; font.pixelSize: 15; Layout.fillWidth: true }

            TextField { id: username; placeholderText: "Username"; text: "admin"; Layout.fillWidth: true }
            TextField { id: password; placeholderText: "Password"; text: "ChangeMe123!"; echoMode: TextInput.Password; Layout.fillWidth: true; onAccepted: login.clicked() }

            Label {
                visible: appController.auth.error.length > 0
                text: appController.auth.error
                color: "#ff8f99"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            ActionButton {
                id: login
                text: "Login"
                Layout.fillWidth: true
                onClicked: appController.auth.login(username.text, password.text)
            }

            Label {
                text: "Default admin password should be changed after first launch."
                color: "#ffbf47"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
