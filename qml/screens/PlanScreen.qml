import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning
import "../components"

Item {
    id: root
    property real pendingAltitude: 50

    Dialog {
        id: altitudeDialog
        title: "New Mission"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        ColumnLayout {
            width: 300
            Label { text: "Mission altitude"; color: "#e6f3ff" }
            SpinBox { id: altitudeSpin; from: 5; to: 500; value: 50; editable: true; Layout.fillWidth: true }
        }
        onAccepted: appController.missions.newMission(altitudeSpin.value)
    }

    Dialog {
        id: landDialog
        title: "Landing"
        modal: true
        ColumnLayout {
            width: 320
            ActionButton { text: "Land at Last Waypoint"; Layout.fillWidth: true; severity: "critical"; onClicked: { appController.missions.addLandAtLastWaypoint(); landDialog.close() } }
            ActionButton { text: "Land at Home"; Layout.fillWidth: true; severity: "critical"; onClicked: { appController.missions.addLandAtHome(appController.telemetry.latitude, appController.telemetry.longitude); landDialog.close() } }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

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
                id: missionMap
                anchors.fill: parent
                plugin: osmPlugin
                center: QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
                zoomLevel: 15
                copyrightsVisible: false

                Component.onCompleted: {
                    for (let i = 0; i < supportedMapTypes.length; ++i) {
                        if (supportedMapTypes[i].name.indexOf("Custom") >= 0) {
                            activeMapType = supportedMapTypes[i]
                            return
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: appController.missions.editing
                    acceptedButtons: Qt.LeftButton
                    onClicked: mouse => {
                        const coordinate = missionMap.toCoordinate(Qt.point(mouse.x, mouse.y), false)
                        appController.missions.addWaypoint(coordinate.latitude, coordinate.longitude)
                    }
                }

                MapQuickItem {
                    coordinate: QtPositioning.coordinate(appController.telemetry.latitude, appController.telemetry.longitude)
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

                MapItemView {
                    model: appController.missions
                    delegate: MapQuickItem {
                        coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                        anchorPoint.x: 14
                        anchorPoint.y: 14
                        sourceItem: Rectangle {
                            width: 28
                            height: 28
                            radius: 14
                            color: model.command.indexOf("LAND") >= 0 ? "#ff4f5e" : model.command.indexOf("TAKEOFF") >= 0 ? "#37d67a" : "#1f78d1"
                            border.color: "#ffffff"
                            Label { anchors.centerIn: parent; text: model.sequence; color: "white"; font.bold: true }
                        }
                    }
                }

                MapPolyline {
                    line.width: 3
                    line.color: "#1f78d1"
                    path: appController.missions.missionPath
                }
            }

            Label {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 16
                text: appController.missions.editing ? "Click map to add waypoints" : appController.missions.uploadStatus
                color: "#dcecff"
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                ActionButton { text: appController.missions.editing ? "Land" : appController.missions.uploadStatus === "Ready to upload" ? "Upload" : "New Mission"; Layout.fillWidth: true; onClicked: appController.missions.editing ? landDialog.open() : appController.missions.uploadStatus === "Ready to upload" ? appController.missions.uploadMission() : altitudeDialog.open() }
                ActionButton { text: "Clear"; severity: "warning"; onClicked: appController.missions.clearMission() }
            }
            RowLayout {
                Layout.fillWidth: true
                ActionButton { text: "Load"; Layout.fillWidth: true; onClicked: appController.missions.downloadMission() }
                ActionButton { text: "Verify"; Layout.fillWidth: true; onClicked: appController.missions.downloadMission() }
            }
            ProgressBar { value: appController.missions.uploadProgress / 100; Layout.fillWidth: true }
            Label { text: appController.missions.uploadStatus; color: "#a9c1d6"; Layout.fillWidth: true }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                model: appController.missions
                delegate: MissionWaypointEditor {
                    width: ListView.view.width
                    sequence: model.sequence
                    command: model.command
                    latitude: model.latitude
                    longitude: model.longitude
                    altitude: model.altitude
                }
            }
        }
    }
}
