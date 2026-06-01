import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool active: false
    implicitHeight: 42
    font.pixelSize: 15

    background: Rectangle {
        radius: 6
        color: control.active ? "#1f78d1" : control.hovered ? "#102940" : "transparent"
        border.color: control.active ? "#5bb0ff" : "#25455f"
        border.width: control.active || control.hovered ? 1 : 0
    }

    contentItem: Text {
        text: control.text
        color: "#eef7ff"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font: control.font
    }
}
