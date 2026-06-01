import QtQuick
import QtQuick.Controls

Button {
    id: control
    implicitWidth: 38
    implicitHeight: 38
    font.pixelSize: 14

    ToolTip.visible: hovered
    ToolTip.delay: 450
    ToolTip.text: text

    background: Rectangle {
        radius: 6
        color: control.down ? "#193d5e" : control.hovered ? "#12304b" : "#0b1b2ccc"
        border.color: control.hovered ? "#5bb0ff" : "#31536d"
        border.width: 1
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? "#eaf7ff" : "#8493a0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pixelSize: control.font.pixelSize
        elide: Text.ElideRight
    }
}
