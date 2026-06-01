import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#0b1b2c"
    border.color: "#18354f"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 14

        Label { text: appController.auth.username + " | " + appController.auth.role; color: "#dcecff"; font.pixelSize: 14 }
        Rectangle { width: 1; Layout.fillHeight: true; color: "#24415d"; Layout.topMargin: 14; Layout.bottomMargin: 14 }
        Label { text: appController.connection.status; color: appController.connection.connected ? "#37d67a" : "#ffbf47"; font.pixelSize: 14; Layout.fillWidth: true }
        Label { text: "Mode " + appController.telemetry.flightMode; color: "#dcecff" }
        Label { text: "GPS " + appController.telemetry.gpsFixType + " / " + appController.telemetry.gpsSatellites; color: "#dcecff" }
        Label { text: Math.round(appController.telemetry.batteryPercent) + "%"; color: appController.telemetry.batteryPercent < 25 ? "#ff4f5e" : "#37d67a"; font.bold: true }
    }
}
