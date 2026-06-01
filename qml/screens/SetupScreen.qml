import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    TabBar {
        id: tabs
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 46
        TabButton { text: "Parameters" }
        TabButton { text: "Safety" }
        TabButton { text: "Sensor Calibration" }
        TabButton { text: "Summary" }
        TabButton { text: "Radio Calibration" }
    }

    StackLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tabs.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 16
        currentIndex: tabs.currentIndex

        ParameterEditor {}

        Flickable {
            contentWidth: width
            contentHeight: safetyColumn.height
            clip: true
            ColumnLayout {
                id: safetyColumn
                width: parent.width
                spacing: 12
                Label { text: "Failsafe Configuration"; color: "#eef8ff"; font.pixelSize: 22; font.bold: true }
                Repeater {
                    model: ["RC failsafe", "GCS failsafe", "GPS/EKF failsafe", "Battery failsafe"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 76
                        radius: 6
                        color: "#0b1e31"
                        border.color: "#203b55"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            Label { text: modelData; color: "#dcecff"; Layout.fillWidth: true }
                            ComboBox { model: ["None", "Land", "RTL", "SmartRTL", "Brake"]; enabled: appController.permissions.can(appController.auth.role, "safety.write") }
                            TextField { placeholderText: "RTL altitude"; enabled: appController.permissions.can(appController.auth.role, "safety.write"); Layout.preferredWidth: 120 }
                        }
                    }
                }
                ActionButton {
                    text: "Write Safety Settings"
                    enabled: appController.permissions.can(appController.auth.role, "safety.write")
                    severity: "warning"
                    onClicked: appController.audit.record(appController.auth.username, "safety_setting_change", "failsafe write requested")
                }
            }
        }

        GridLayout {
            columns: width > 760 ? 3 : 1
            rowSpacing: 12
            columnSpacing: 12
            CalibrationPanel { Layout.fillWidth: true; Layout.fillHeight: true; title: "Compass"; description: "Rotate the vehicle through all axes and wait for completion." }
            CalibrationPanel { Layout.fillWidth: true; Layout.fillHeight: true; title: "Accelerometer"; description: "Place the vehicle on each requested side and confirm each step." }
            CalibrationPanel { Layout.fillWidth: true; Layout.fillHeight: true; title: "Level"; description: "Set the vehicle level on a stable surface before starting." }
        }

        Flickable {
            contentWidth: width
            contentHeight: summaryGrid.height
            clip: true
            GridLayout {
                id: summaryGrid
                width: parent.width
                columns: width > 700 ? 3 : 2
                rowSpacing: 10
                columnSpacing: 10
                Repeater {
                    model: [
                        ["Firmware", "ArduPilot SITL"], ["Vehicle", "Multicopter"], ["Frame", "Quad X"],
                        ["Board", "SITL"], ["Autopilot", "4.x"], ["MAVLink", "2"],
                        ["RGCS", "0.1.0"], ["Parameters", "Pending load"], ["Mission", appController.missions.uploadStatus],
                        ["GPS", appController.telemetry.gpsFixType], ["Battery", Math.round(appController.telemetry.batteryPercent) + "%"], ["Logging", appController.settings.telemetryLogging ? "Enabled" : "Disabled"]
                    ]
                    delegate: StatusCard { Layout.fillWidth: true; Layout.preferredHeight: 110; title: modelData[0]; value: modelData[1]; accent: "#1f78d1" }
                }
            }
        }

        ColumnLayout {
            spacing: 12
            Label { text: "Radio Calibration"; color: "#eef8ff"; font.pixelSize: 22; font.bold: true }
            Repeater {
                model: ["Roll", "Pitch", "Throttle", "Yaw", "Aux 1", "Aux 2"]
                delegate: RowLayout {
                    Layout.fillWidth: true
                    Label { text: modelData; color: "#dcecff"; Layout.preferredWidth: 90 }
                    ProgressBar { value: index === 2 ? 0.5 : 0.42 + index * 0.06; Layout.fillWidth: true }
                    Label { text: "min 1000 / trim 1500 / max 2000"; color: "#9fb8cc"; Layout.preferredWidth: 220 }
                }
            }
            RowLayout {
                ActionButton { text: "Start"; enabled: appController.permissions.can(appController.auth.role, "calibration.run") }
                ActionButton { text: "Save"; severity: "warning"; enabled: appController.permissions.can(appController.auth.role, "calibration.run"); onClicked: appController.audit.record(appController.auth.username, "calibration_command", "radio save") }
                ActionButton { text: "Cancel" }
            }
        }
    }

    Rectangle {
        visible: appController.permissions.can(appController.auth.role, "diagnostics.view")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 18
        width: 360
        height: 162
        radius: 8
        color: "#0b1b2c"
        border.color: "#24415d"
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            DiagnosticGauge { Layout.fillWidth: true; Layout.fillHeight: true; label: "EKF"; value: 0.21 }
            VibrationAxisView { Layout.fillWidth: true; Layout.fillHeight: true; imu: "IMU 1" }
        }
    }
}
