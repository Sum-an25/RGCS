import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning
import "../components"

Item {
    id: root
    property string viewMode: "Map"
    property string pendingCommand: ""
    property bool trackVisible: true

    function openCommand(command) {
        pendingCommand = command
        confirm.askAltitude = command === "takeoff"
        confirm.requireSlide = command === "rtl" || command === "land"
        confirm.prompt = commandPrompt(command)
        confirm.open()
    }

    function commandPrompt(command) {
        if (command === "takeoff")
            return "Enter take-off altitude. RGCS will verify connection, role permission, and vehicle state before sending."
        if (command === "start mission")
            return "Review mission status before start. RGCS will wait for vehicle acknowledgement after sending."
        if (command === "rtl")
            return "Return-to-launch changes vehicle navigation immediately. Slide only after confirming the flight area is clear."
        if (command === "land")
            return "Land commands descend the vehicle at its current target. Slide only after confirming the landing area is safe."
        return "Confirm " + command + " command. RGCS will check connection, role permission, and vehicle state before sending."
    }

    ConfirmDialog {
        id: confirm
        commandName: root.pendingCommand
        onAcceptedCommand: value => appController.commands.sendCriticalCommand(root.pendingCommand, value)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
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
                    visible: root.viewMode !== "Video"
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

                    MapCircle {
                        center: QtPositioning.coordinate(appController.telemetry.latitude - 0.0010, appController.telemetry.longitude - 0.0012)
                        radius: 100
                        color: "#1f78d122"
                        border.width: 2
                        border.color: "#5bb0ff"
                    }

                    MapPolyline {
                        visible: root.trackVisible
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
                        anchorPoint.x: 10
                        anchorPoint.y: 10
                        sourceItem: Item {
                            width: 92
                            height: 30
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: "#37d67a"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                            Label { text: "Home"; color: "#eaf7ff"; x: 26; y: 1; font.bold: true }
                        }
                    }

                    MapQuickItem {
                        coordinate: QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
                        anchorPoint.x: 18
                        anchorPoint.y: 18
                        sourceItem: Item {
                            width: 114
                            height: 48
                            Text {
                                text: "^"
                                x: 4
                                y: -7
                                color: "#ffffff"
                                font.pixelSize: 36
                                font.bold: true
                                rotation: 22
                            }
                            Rectangle {
                                x: 8
                                y: 8
                                width: 22
                                height: 22
                                radius: 11
                                color: "#1f78d1"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                            Label { text: "Vehicle"; color: "#eaf7ff"; x: 38; y: 7; font.bold: true }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: root.viewMode === "Video"
                    color: "#0a0d12"
                    Label {
                        anchors.centerIn: parent
                        text: appController.settings.videoUrl.length ? appController.settings.videoUrl : "Video stream standby"
                        color: "#9fb8cc"
                        font.pixelSize: 20
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    Repeater {
                        model: ["Map", "Video", "Split"]
                        delegate: Button {
                            text: modelData
                            checkable: true
                            checked: root.viewMode === modelData
                            implicitHeight: 36
                            implicitWidth: 72
                            onClicked: root.viewMode = modelData
                            background: Rectangle {
                                radius: 6
                                color: parent.checked ? "#1f78d1" : parent.hovered ? "#12304bcc" : "#0b1b2ccc"
                                border.color: parent.checked ? "#8dccff" : "#31536d"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#eef7ff"
                                font.bold: parent.checked
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    spacing: 6

                    MapControlButton { text: "+"; onClicked: flightMap.zoomLevel = Math.min(flightMap.maximumZoomLevel, flightMap.zoomLevel + 1) }
                    MapControlButton { text: "-"; onClicked: flightMap.zoomLevel = Math.max(flightMap.minimumZoomLevel, flightMap.zoomLevel - 1) }
                    MapControlButton { text: "R"; onClicked: flightMap.center = QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude) }
                    MapControlButton { text: "N"; onClicked: flightMap.bearing = 0 }
                    MapControlButton { text: "C"; onClicked: root.trackVisible = false }
                    MapControlButton { text: "T"; onClicked: root.trackVisible = !root.trackVisible }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    width: 118
                    height: 124
                    radius: 8
                    color: "#0b1b2ccc"
                    border.color: "#31536d"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 74
                            height: 74
                            radius: 37
                            color: "#12304b"
                            border.color: "#5bb0ff"
                            clip: true

                            Rectangle { x: 0; y: 37; width: 74; height: 37; color: "#31502f" }
                            Rectangle { x: 12; y: 36; width: 50; height: 2; color: "#ffffff" }
                            Rectangle { x: 36; y: 12; width: 2; height: 50; color: "#9fc7e8" }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "HDG 022"
                            color: "#eaf7ff"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    radius: 6
                    color: "#0b1b2ccc"
                    border.color: "#24415d"
                    width: attribution.width + 24
                    height: 30
                    Label {
                        id: attribution
                        anchors.centerIn: parent
                        text: "OpenStreetMap"
                        color: "#9fb8cc"
                        font.pixelSize: 11
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 318
                Layout.fillHeight: true
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    text: "Telemetry"
                    color: "#e8f3ff"
                    font.pixelSize: 18
                    font.bold: true
                }

                TelemetryGroup {
                    Layout.fillWidth: true
                    title: "Vehicle"
                    TelemetryCard { Layout.fillWidth: true; label: "Flight Mode"; value: appController.telemetry.flightMode }
                    TelemetryCard { Layout.fillWidth: true; label: "Arm Status"; value: appController.telemetry.armStatus }
                    TelemetryCard { Layout.fillWidth: true; label: "Altitude"; value: appController.telemetry.altitude.toFixed(1); unit: "m" }
                    TelemetryCard { Layout.fillWidth: true; label: "Vertical Speed"; value: appController.telemetry.verticalSpeed.toFixed(1); unit: "m/s" }
                    TelemetryCard { Layout.fillWidth: true; label: "Horizontal Speed"; value: appController.telemetry.horizontalSpeed.toFixed(1); unit: "m/s" }
                }

                TelemetryGroup {
                    Layout.fillWidth: true
                    title: "Navigation"
                    TelemetryCard { Layout.fillWidth: true; label: "Distance Home"; value: appController.telemetry.distanceFromHome.toFixed(0); unit: "m" }
                    TelemetryCard { Layout.fillWidth: true; label: "Travelled"; value: appController.telemetry.travelledDistance.toFixed(0); unit: "m" }
                    TelemetryCard { Layout.fillWidth: true; label: "GPS Satellites"; value: appController.telemetry.gpsSatellites }
                    TelemetryCard { Layout.fillWidth: true; label: "GPS Fix"; value: appController.telemetry.gpsFixType }
                }

                TelemetryGroup {
                    Layout.fillWidth: true
                    title: "Power"
                    TelemetryCard { Layout.fillWidth: true; label: "Battery"; value: Math.round(appController.telemetry.batteryPercent); unit: "%" }
                    TelemetryCard { Layout.fillWidth: true; label: "Voltage"; value: appController.telemetry.batteryVoltage.toFixed(1); unit: "V" }
                    TelemetryCard { Layout.fillWidth: true; label: "Current"; value: "--"; unit: "A" }
                    TelemetryCard { Layout.fillWidth: true; label: "Remaining"; value: "--" }
                }

                TelemetryGroup {
                    Layout.fillWidth: true
                    title: "Link"
                    TelemetryCard { Layout.fillWidth: true; label: "Telemetry Link"; value: appController.telemetry.telemetryLink }
                    TelemetryCard { Layout.fillWidth: true; label: "RC Signal"; value: appController.telemetry.rcSignal; unit: "%" }
                    TelemetryCard { Layout.fillWidth: true; label: "Packet Loss"; value: "--"; unit: "%" }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#0b1b2c"
                    border.color: "#24415d"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6
                        Label { text: "Command Feedback"; color: "#e8f3ff"; font.bold: true }
                        Label {
                            Layout.fillWidth: true
                            text: appController.commands.lastResult
                            color: "#a9c1d6"
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            radius: 8
            color: "#0b1b2c"
            border.color: "#24415d"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Repeater {
                    model: [
                        { label: "ARM", command: "arm", severity: "normal" },
                        { label: "TAKE-OFF", command: "takeoff", severity: "normal" },
                        { label: "START MISSION", command: "start mission", severity: "success" },
                        { label: "PAUSE", command: "pause", severity: "warning" },
                        { label: "RTL", command: "rtl", severity: "warning" },
                        { label: "LAND", command: "land", severity: "critical" }
                    ]
                    delegate: ActionButton {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 96
                        text: modelData.label
                        severity: modelData.severity
                        enabled: appController.commands.canRun(modelData.command)
                        onClicked: root.openCommand(modelData.command)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            radius: 6
            color: "#081827"
            border.color: "#18354f"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 16

                FooterMetric { label: "Link"; value: appController.telemetry.telemetryLink; healthy: appController.connection.connected }
                FooterMetric { label: "RC"; value: appController.telemetry.rcSignal + "%"; healthy: appController.telemetry.rcSignal > 50 }
                FooterMetric { label: "Alt"; value: appController.telemetry.altitude.toFixed(1) + " m"; healthy: appController.connection.connected }
                FooterMetric { label: "Air"; value: appController.telemetry.timeInAir; healthy: appController.connection.connected }
                FooterMetric { label: "Home"; value: appController.telemetry.distanceFromHome.toFixed(0) + " m"; healthy: appController.connection.connected }
                Item { Layout.fillWidth: true }
            }
        }
    }

    component FooterMetric: RowLayout {
        property string label: ""
        property string value: ""
        property bool healthy: false
        spacing: 6

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: healthy ? "#37d67a" : "#8493a0"
        }

        Label { text: label; color: "#7f9bb0"; font.pixelSize: 11 }
        Label { text: value; color: "#dcecff"; font.pixelSize: 11; font.bold: true }
    }
}
