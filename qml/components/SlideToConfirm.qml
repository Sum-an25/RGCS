import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string text: "Slide to confirm"
    signal confirmed()
    height: 44

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#3a1420"
        border.color: "#b73b4c"
        Text { anchors.centerIn: parent; text: root.text; color: "#ffdce1"; font.bold: true }
    }

    Rectangle {
        id: knob
        width: 58
        height: parent.height
        radius: 6
        color: "#ff4f5e"
        Text { anchors.centerIn: parent; text: ">"; color: "white"; font.bold: true }
        MouseArea {
            anchors.fill: parent
            drag.target: knob
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: root.width - knob.width
            onReleased: {
                if (knob.x > root.width - knob.width - 12) root.confirmed()
                knob.x = 0
            }
        }
    }
}
