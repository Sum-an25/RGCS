import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property alias title: titleLabel.text
    property alias value: valueLabel.text
    property string accent: "#37d67a"
    signal clicked()
    radius: 8
    color: "#0d2236"
    border.color: "#21415d"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        Label { id: titleLabel; color: "#9fb8cc"; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
        Label { id: valueLabel; color: "#eff8ff"; font.pixelSize: 24; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
        Rectangle { height: 3; radius: 2; color: root.accent; Layout.fillWidth: true }
    }

    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
