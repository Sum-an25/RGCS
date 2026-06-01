import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string imu: "IMU"
    radius: 6
    color: "#0b1e31"
    border.color: "#203b55"
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        Label { text: imu; color: "#f2fbff"; font.bold: true }
        Repeater {
            model: ["X", "Y", "Z"]
            delegate: ProgressBar { value: 0.25 + index * 0.12; Layout.fillWidth: true }
        }
    }
}
