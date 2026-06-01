import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string severity: "normal"
    implicitHeight: 46
    font.pixelSize: 13

    background: Rectangle {
        radius: 6
        color: {
            if (!control.enabled)
                return "#26323d"
            if (control.down)
                return control.severity === "critical" ? "#7d1a28" : control.severity === "warning" ? "#84520f" : "#1760aa"
            return control.severity === "critical" ? "#a52435" : control.severity === "warning" ? "#b87416" : control.severity === "success" ? "#1f8a57" : "#1f78d1"
        }
        border.color: control.hovered || control.activeFocus ? "#d9efff" : "#31536d"
        border.width: control.enabled ? 1 : 0

        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? "#ffffff" : "#8493a0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pixelSize: control.font.pixelSize
        elide: Text.ElideRight
    }
}
