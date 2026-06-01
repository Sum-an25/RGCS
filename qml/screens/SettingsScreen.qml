import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Flickable {
    contentWidth: width
    contentHeight: form.height + 48
    clip: true

    GridLayout {
        id: form
        width: parent.width
        columns: width > 900 ? 2 : 1
        rowSpacing: 12
        columnSpacing: 18
        anchors.margins: 24

        Label { text: "Settings"; color: "#eef8ff"; font.pixelSize: 28; font.bold: true; Layout.columnSpan: form.columns; Layout.leftMargin: 24; Layout.topMargin: 24 }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 330
            radius: 8
            color: "#0b1e31"
            border.color: "#203b55"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Label { text: "Connection"; color: "#eef8ff"; font.pixelSize: 18; font.bold: true }
                ComboBox {
                    property var options: ["UDP", "TCP", "Serial"]
                    model: options
                    currentIndex: options.indexOf(appController.connection.linkType)
                    onActivated: appController.connection.linkType = currentText
                    Layout.fillWidth: true
                }
                TextField { text: appController.connection.endpoint; placeholderText: "Endpoint or serial device"; onEditingFinished: appController.connection.endpoint = text; Layout.fillWidth: true }
                SpinBox { from: 1; to: 65535; value: appController.connection.port; editable: true; onValueModified: appController.connection.port = value; Layout.fillWidth: true }
                RowLayout {
                    Layout.fillWidth: true
                    ActionButton { text: appController.connection.connected ? "Disconnect" : "Connect"; Layout.fillWidth: true; onClicked: appController.connection.connected ? appController.connection.disconnectLink() : appController.connection.connectLink() }
                    ActionButton { text: "Save"; Layout.fillWidth: true; onClicked: appController.settings.save() }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 330
            radius: 8
            color: "#0b1e31"
            border.color: "#203b55"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Label { text: "Map and Coordinates"; color: "#eef8ff"; font.pixelSize: 18; font.bold: true }
                ComboBox {
                    property var providers: ["OpenStreetMap", "Bing", "Google", "Offline tiles"]
                    model: providers
                    currentIndex: providers.indexOf(appController.settings.mapProvider)
                    onActivated: appController.settings.mapProvider = currentText
                    Layout.fillWidth: true
                }
                ComboBox {
                    property var coordinateOptions: ["Degree Decimal", "Degree Minute Second", "MGRS"]
                    model: coordinateOptions
                    currentIndex: coordinateOptions.indexOf(appController.settings.coordinateType)
                    onActivated: appController.settings.coordinateType = currentText
                    Layout.fillWidth: true
                }
                Label { text: appController.coordinates.decimalDegrees(appController.telemetry.latitude, appController.telemetry.longitude); color: "#a9c1d6" }
                CheckBox { text: "Outdoor high-contrast mode"; checked: appController.settings.outdoorMode; onToggled: appController.settings.outdoorMode = checked }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            radius: 8
            color: "#0b1e31"
            border.color: "#203b55"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Label { text: "Video"; color: "#eef8ff"; font.pixelSize: 18; font.bold: true }
                ComboBox {
                    property var videoOptions: ["RTSP", "UDP H264", "UDP H265", "HTTP"]
                    model: videoOptions
                    currentIndex: videoOptions.indexOf(appController.settings.videoType)
                    onActivated: appController.settings.videoType = currentText
                    Layout.fillWidth: true
                }
                TextField { text: appController.settings.videoUrl; placeholderText: "Stream URL or port"; onEditingFinished: appController.settings.videoUrl = text; Layout.fillWidth: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            radius: 8
            color: "#0b1e31"
            border.color: "#203b55"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Label { text: "Logging and IDs"; color: "#eef8ff"; font.pixelSize: 18; font.bold: true }
                RowLayout { Label { text: "Vehicle ID"; color: "#dcecff"; Layout.fillWidth: true } SpinBox { from: 1; to: 255; value: 1 } }
                RowLayout { Label { text: "System ID"; color: "#dcecff"; Layout.fillWidth: true } SpinBox { from: 1; to: 255; value: 255 } }
                RowLayout { Label { text: "Component ID"; color: "#dcecff"; Layout.fillWidth: true } SpinBox { from: 1; to: 255; value: 190 } }
                CheckBox { text: "Save telemetry log locally"; checked: appController.settings.telemetryLogging; onToggled: appController.settings.telemetryLogging = checked }
                CheckBox { text: "Start logging when disarmed"; checked: true }
                TextField { placeholderText: "Log folder path"; Layout.fillWidth: true }
            }
        }
    }
}
