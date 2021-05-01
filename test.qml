import QtQuick 2.15
import QtQuick.Layouts 1.15
import S5WDials 1.0

RowLayout {
    spacing: 3
    anchors.fill: parent

    Timer {
        interval: 500
        running: true
        repeat: true

        signal sensorOutput(real val)

        id: cpu_meter
        property real lastTotal: 0
        property real lastUser:  0

        onTriggered: {
            var doc = new XMLHttpRequest();
            doc.onreadystatechange = function() {
                if(doc.readyState !== XMLHttpRequest.DONE) {
                    return;
                }

                var resp = doc.responseText;
                var lines = resp.split("\n");
                var cpu_usage = lines[0].replace(/ +/g, ' ').split(' ').map(i => +i);
                var total =  +cpu_usage[1] + cpu_usage[2] + cpu_usage[3] +
                        cpu_usage[4] + cpu_usage[5] + cpu_usage[6] + cpu_usage[7];
                var user =  +cpu_usage[1] + cpu_usage[2] + cpu_usage[3];

                var user_load = 100.0 * (user - cpu_meter.lastUser) / (total - cpu_meter.lastTotal);

                cpu_meter.sensorOutput(user_load);

                cpu_meter.lastUser = user;
                cpu_meter.lastTotal = total;
            }
            doc.open('GET', '/proc/stat');
            doc.send();
        }
    }

    S5WDial {
        id: base_dial
        minimum: 0.0
        maximum: 100.0

        Layout.minimumHeight: 100
        Layout.minimumWidth: 100
        Layout.fillHeight: true
        Layout.fillWidth: true

        numTicks: 10
        label: "CPU Load (%)"

        useWarningArea: true
        warnLow: 80.0
        warnHigh: 100.0

        Connections {
            target: cpu_meter
            function onSensorOutput(value) {
                base_dial.value = value
            }
        }
    }

    S5WDial {
        id: base_dial_narrow
        minimum: 0.0
        maximum: 40.0

        Layout.minimumHeight: 100
        Layout.minimumWidth: 100
        Layout.fillHeight: true
        Layout.fillWidth: true

        numTicks: 8
        label: "CPU Load, Low (%)"

        useDesiredArea: true
        desiredLow: 0.0
        desiredHigh: 10.0

        Connections {
            target: cpu_meter
            function onSensorOutput(value) {
                base_dial_narrow.value = value
            }
        }
    }
}
