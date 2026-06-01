import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#0b1b2c"
    border.color: "#18354f"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 10

        Label { text: "RGCS"; color: "#e8f3ff"; font.pixelSize: 18; font.bold: true }
        Rectangle { width: 1; Layout.fillHeight: true; color: "#24415d"; Layout.topMargin: 13; Layout.bottomMargin: 13 }
        Label { text: "Operator " + appController.auth.username + " (" + appController.auth.role + ")"; color: "#9fb8cc"; font.pixelSize: 12; Layout.preferredWidth: 190; elide: Text.ElideRight }
        Label { text: "UTC " + Qt.formatDateTime(new Date(), "hh:mm"); color: "#9fb8cc"; font.pixelSize: 12 }
        Item { Layout.fillWidth: true }
        StatusPill { label: "Link"; value: appController.connection.status; stateColor: appController.connection.connected ? "#37d67a" : "#ffbf47" }
        StatusPill { label: "Arm"; value: appController.telemetry.armStatus; stateColor: appController.telemetry.armStatus === "DISARMED" ? "#9fb8cc" : "#37d67a" }
        StatusPill { label: "Mode"; value: appController.telemetry.flightMode; stateColor: "#5bb0ff" }
        StatusPill { label: "Batt"; value: Math.round(appController.telemetry.batteryPercent) + "% / " + appController.telemetry.batteryVoltage.toFixed(1) + "V"; stateColor: appController.telemetry.batteryPercent < 25 ? "#ff4f5e" : "#37d67a" }
        StatusPill { label: "GPS"; value: appController.telemetry.gpsFixType + " / " + appController.telemetry.gpsSatellites; stateColor: appController.telemetry.gpsSatellites >= 10 ? "#37d67a" : "#ffbf47" }
        StatusPill { label: "Nav"; value: appController.telemetry.telemetryLink; stateColor: appController.connection.connected ? "#5bb0ff" : "#8493a0" }
    }

    component StatusPill: Rectangle {
        property string label: ""
        property string value: ""
        property color stateColor: "#8493a0"

        Layout.preferredHeight: 36
        Layout.minimumWidth: 86
        radius: 6
        color: "#10263a"
        border.color: "#24415d"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: stateColor
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                Label { text: label; color: "#7f9bb0"; font.pixelSize: 9; Layout.fillWidth: true; elide: Text.ElideRight }
                Label { text: value; color: "#f4fbff"; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
            }
        }
    }
}
