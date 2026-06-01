import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    property bool expanded: true
    default property alias content: body.data

    radius: 8
    color: "#0b1b2c"
    border.color: "#24415d"
    implicitHeight: header.implicitHeight + (expanded ? body.implicitHeight + 18 : 14)
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        RowLayout {
            id: header
            Layout.fillWidth: true
            implicitHeight: 26

            Label {
                text: root.title
                color: "#e8f3ff"
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: root.expanded ? "-" : "+"
                implicitWidth: 28
                implicitHeight: 24
                onClicked: root.expanded = !root.expanded
                background: Rectangle {
                    radius: 4
                    color: parent.hovered ? "#12304b" : "transparent"
                    border.color: parent.hovered ? "#31536d" : "transparent"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#9fc7e8"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }
        }

        ColumnLayout {
            id: body
            visible: root.expanded
            Layout.fillWidth: true
            spacing: 4
        }
    }
}
