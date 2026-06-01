import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool active: false
    property string iconText: ""
    implicitHeight: 42
    font.pixelSize: 15

    ToolTip.visible: hovered
    ToolTip.delay: 500
    ToolTip.text: control.text

    background: Rectangle {
        radius: 6
        color: control.active ? "#1f78d1" : control.hovered ? "#102940" : "transparent"
        border.color: control.active ? "#8dccff" : "#25455f"
        border.width: control.active || control.hovered ? 1 : 0
    }

    contentItem: Item {
        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Text {
                width: 20
                anchors.verticalCenter: parent.verticalCenter
                text: control.iconText
                color: control.active ? "#ffffff" : "#9fc7e8"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                width: parent.width - 40
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                color: "#eef7ff"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font: control.font
            }
        }
    }
}
