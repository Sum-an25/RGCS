import QtQuick
import QtQuick.Controls

Rectangle {
    property string label: ""
    property real value: 0
    property real amber: 0.5
    property real red: 0.8
    radius: 6
    color: value > red ? "#3a1420" : value > amber ? "#35260e" : "#0d2c24"
    border.color: value > red ? "#ff4f5e" : value > amber ? "#ffbf47" : "#37d67a"
    Label { anchors.centerIn: parent; text: label + " " + value.toFixed(2); color: "#f5fbff"; font.bold: true }
}
