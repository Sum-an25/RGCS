import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property int sequence: 0
    property string command: ""
    property real latitude: 0
    property real longitude: 0
    property real altitude: 0
    radius: 6
    color: "#0b1e31"
    border.color: "#203b55"
    implicitHeight: 108

    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 4
        Label { text: "#" + sequence; color: "#8fb2cc"; font.bold: true }
        Label { text: command; color: "#e9f5ff"; Layout.columnSpan: 3; elide: Text.ElideRight; Layout.fillWidth: true }
        TextField { text: latitude.toFixed(7); Layout.fillWidth: true }
        TextField { text: longitude.toFixed(7); Layout.fillWidth: true }
        TextField { text: altitude.toFixed(1); Layout.fillWidth: true }
        ComboBox {
            property var commandOptions: ["MAV_CMD_NAV_WAYPOINT", "MAV_CMD_NAV_TAKEOFF", "MAV_CMD_NAV_LAND"]
            model: commandOptions
            currentIndex: Math.max(0, commandOptions.indexOf(command))
            Layout.fillWidth: true
        }
    }
}
