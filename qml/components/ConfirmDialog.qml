import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    property string commandName: ""
    property string prompt: ""
    property bool askAltitude: false
    property bool requireSlide: false
    property real altitude: 30
    signal acceptedCommand(real value)

    title: commandName.toUpperCase()
    modal: true
    standardButtons: requireSlide ? Dialog.Cancel : Dialog.Cancel | Dialog.Ok

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

        SlideToConfirm {
            visible: dialog.requireSlide
            Layout.fillWidth: true
            text: "Slide to confirm " + dialog.commandName.toUpperCase()
            onConfirmed: {
                dialog.acceptedCommand(0)
                dialog.close()
            }
        }
    }

    onAccepted: acceptedCommand(askAltitude ? altitude : 0)
}
