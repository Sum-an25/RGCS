import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning
import "../components"

Item {
    id: root
    property string viewMode: "Split"
    property string pendingCommand: ""

    ConfirmDialog {
        id: confirm
        commandName: root.pendingCommand
        prompt: "Confirm " + root.pendingCommand + " command. RGCS will check connection, role permission, and vehicle state before sending."
        askAltitude: root.pendingCommand === "takeoff"
        onAcceptedCommand: value => appController.commands.sendCriticalCommand(root.pendingCommand, value)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                RowLayout {
                    spacing: 4
                    Button { text: "Map"; checkable: true; checked: root.viewMode === "Map"; onClicked: root.viewMode = "Map" }
                    Button { text: "Video"; checkable: true; checked: root.viewMode === "Video"; onClicked: root.viewMode = "Video" }
                    Button { text: "Split"; checkable: true; checked: root.viewMode === "Split"; onClicked: root.viewMode = "Split" }
                }
                Item { Layout.fillWidth: true }
                Label { text: appController.telemetry.telemetryLink; color: appController.connection.connected ? "#37d67a" : "#ffbf47"; font.bold: true }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Rectangle {
                    visible: root.viewMode !== "Video"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#10263a"
                    border.color: "#24415d"
                    clip: true

                    Plugin {
                        id: osmPlugin
                        name: "osm"
                        PluginParameter {
                            name: "osm.mapping.providersrepository.disabled"
                            value: true
                        }
                        PluginParameter {
                            name: "osm.mapping.custom.host"
                            value: "https://tile.openstreetmap.org/%z/%x/%y.png"
                        }
                    }

                    Map {
                        id: flightMap
                        anchors.fill: parent
                        plugin: osmPlugin
                        center: QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
                        zoomLevel: 16
                        copyrightsVisible: false

                        Component.onCompleted: {
                            for (let i = 0; i < supportedMapTypes.length; ++i) {
                                if (supportedMapTypes[i].name.indexOf("Custom") >= 0) {
                                    activeMapType = supportedMapTypes[i]
                                    return
                                }
                            }
                        }

                        MapPolyline {
                            line.width: 3
                            line.color: "#37d67a"
                            path: [
                                QtPositioning.coordinate(appController.telemetry.latitude - 0.0010, appController.telemetry.longitude - 0.0012),
                                QtPositioning.coordinate(appController.telemetry.latitude - 0.0006, appController.telemetry.longitude - 0.0005),
                                QtPositioning.coordinate(appController.telemetry.latitude - 0.0002, appController.telemetry.longitude - 0.0001),
                                QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
                            ]
                        }

                        MapQuickItem {
                            coordinate: QtPositioning.coordinate(appController.telemetry.latitude - 0.0010, appController.telemetry.longitude - 0.0012)
                            anchorPoint.x: 8
                            anchorPoint.y: 8
                            sourceItem: Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: "#37d67a"
                                border.color: "#ffffff"
                                Label { text: "Home"; color: "#dcecff"; x: 22; y: -2 }
                            }
                        }

                        MapQuickItem {
                            coordinate: QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
                            anchorPoint.x: 12
                            anchorPoint.y: 12
                            sourceItem: Item {
                                width: 92
                                height: 46
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: "#1f78d1"
                                    border.color: "#ffffff"
                                    border.width: 2
                                }
                                Label { text: "Vehicle"; color: "#eaf7ff"; x: 30; y: 2; font.bold: true }
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 12
                        radius: 6
                        color: "#0b1b2c"
                        border.color: "#24415d"
                        width: mapStatus.width + 24
                        height: 36
                        Label {
                            id: mapStatus
                            anchors.centerIn: parent
                            text: "OpenStreetMap"
                            color: "#dcecff"
                        }
                    }
                }

                Rectangle {
                    visible: root.viewMode !== "Map"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#0a0d12"
                    border.color: "#24415d"
                    Label { anchors.centerIn: parent; text: appController.settings.videoUrl.length ? appController.settings.videoUrl : "Video stream standby"; color: "#9fb8cc"; font.pixelSize: 20 }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 330
            Layout.fillHeight: true
            spacing: 8

            TelemetryGroup {
                Layout.fillWidth: true
                TelemetryCard { Layout.fillWidth: true; label: "Arm"; value: appController.telemetry.armStatus }
                TelemetryCard { Layout.fillWidth: true; label: "Mode"; value: appController.telemetry.flightMode }
                TelemetryCard { Layout.fillWidth: true; label: "Battery"; value: Math.round(appController.telemetry.batteryPercent); unit: "%" }
                TelemetryCard { Layout.fillWidth: true; label: "Voltage"; value: appController.telemetry.batteryVoltage.toFixed(1); unit: "V" }
                TelemetryCard { Layout.fillWidth: true; label: "Altitude"; value: appController.telemetry.altitude.toFixed(1); unit: "m" }
                TelemetryCard { Layout.fillWidth: true; label: "V Speed"; value: appController.telemetry.verticalSpeed.toFixed(1); unit: "m/s" }
                TelemetryCard { Layout.fillWidth: true; label: "H Speed"; value: appController.telemetry.horizontalSpeed.toFixed(1); unit: "m/s" }
                TelemetryCard { Layout.fillWidth: true; label: "Distance"; value: appController.telemetry.distanceFromHome.toFixed(0); unit: "m" }
                TelemetryCard { Layout.fillWidth: true; label: "Travelled"; value: appController.telemetry.travelledDistance.toFixed(0); unit: "m" }
                TelemetryCard { Layout.fillWidth: true; label: "RC"; value: appController.telemetry.rcSignal; unit: "%" }
            }

            Label { text: appController.commands.lastResult; color: "#a9c1d6"; wrapMode: Text.WordWrap; Layout.fillWidth: true }

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Repeater {
                    model: [
                        { label: "Arm", command: "arm", severity: "normal" },
                        { label: "Disarm", command: "disarm", severity: "warning" },
                        { label: "Takeoff", command: "takeoff", severity: "normal" },
                        { label: "Start Mission", command: "start mission", severity: "normal" },
                        { label: "Pause", command: "pause", severity: "warning" },
                        { label: "RTL", command: "rtl", severity: "critical" },
                        { label: "Land", command: "land", severity: "critical" }
                    ]
                    delegate: ActionButton {
                        Layout.fillWidth: true
                        text: modelData.label
                        severity: modelData.severity
                        enabled: appController.commands.canRun(modelData.command)
                        onClicked: { root.pendingCommand = modelData.command; confirm.open() }
                    }
                }
            }
        }
    }
}
