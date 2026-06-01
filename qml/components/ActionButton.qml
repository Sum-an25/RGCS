import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string severity: "normal"
    implicitHeight: 42

    background: Rectangle {
        radius: 6
        color: !control.enabled ? "#26323d" : control.severity === "critical" ? "#9d2231" : control.severity === "warning" ? "#a56a14" : "#1f78d1"
        border.color: control.hovered ? "#d9efff" : "transparent"
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? "#ffffff" : "#8493a0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        elide: Text.ElideRight
    }
}
