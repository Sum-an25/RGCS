import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string label: ""
    property string value: ""
    property string unit: ""
    radius: 6
    color: "#0b1e31"
    border.color: "#203b55"
    implicitHeight: 62

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        Label { text: label; color: "#9fb8cc"; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
        Label { text: value + (unit.length ? " " + unit : ""); color: "#f4fbff"; font.pixelSize: 18; font.bold: true }
    }
}
