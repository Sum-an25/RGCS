import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string title: "Calibration"
    property string description: ""
    radius: 6
    color: "#0b1e31"
    border.color: "#203b55"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        Label { text: title; color: "#f2fbff"; font.pixelSize: 18; font.bold: true }
        Label { text: description; color: "#a9c1d6"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        ProgressBar { value: 0.0; Layout.fillWidth: true }
        ActionButton { text: "Start"; enabled: appController.permissions.can(appController.auth.role, "calibration.run"); onClicked: appController.audit.record(appController.auth.username, "calibration_command", title) }
    }
}
