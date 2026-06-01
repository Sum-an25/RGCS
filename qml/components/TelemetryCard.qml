import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string label: ""
    property string value: ""
    property string unit: ""
    radius: 6
    color: "#0b1e3100"
    border.color: "transparent"
    implicitHeight: 32

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 8

        Label {
            text: label
            color: "#9fb8cc"
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Label {
            text: value + (unit.length ? " " + unit : "")
            color: "#f4fbff"
            font.pixelSize: 15
            font.bold: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }
}
