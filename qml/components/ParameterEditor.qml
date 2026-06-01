import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    radius: 6
    color: "#0b1e31"
    border.color: "#203b55"
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        TextField { placeholderText: "Search parameters"; Layout.fillWidth: true }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ["ARMING_CHECK", "BATT_FS_LOW_ACT", "FS_THR_ENABLE", "RTL_ALT", "WPNAV_SPEED"]
            delegate: RowLayout {
                width: ListView.view.width
                Label { text: modelData; color: "#dcecff"; Layout.fillWidth: true }
                TextField { text: modelData === "RTL_ALT" ? "1500" : "1"; enabled: appController.permissions.can(appController.auth.role, "parameters.write") }
            }
        }
    }
}
