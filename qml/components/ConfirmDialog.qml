import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    property string commandName: ""
    property string prompt: ""
    property bool askAltitude: false
    property real altitude: 30
    signal acceptedCommand(real value)

    title: commandName
    modal: true
    standardButtons: Dialog.Cancel | Dialog.Ok

    ColumnLayout {
        width: 360
        spacing: 12
        Label { text: prompt; color: "#e6f3ff"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        SpinBox {
            visible: dialog.askAltitude
            from: 5
            to: 500
            value: dialog.altitude
            editable: true
            onValueChanged: dialog.altitude = value
            Layout.fillWidth: true
        }
    }

    onAccepted: acceptedCommand(askAltitude ? altitude : 0)
}
