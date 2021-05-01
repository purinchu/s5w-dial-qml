import QtQuick 2.15
import S5WDials 1.0

Row {
    spacing: 3

    Rectangle {
        width: 100
        height: 100
        color: "red"
    }

    S5WDial {
        id: base_dial
        minimum: 0.0
        maximum: 100.0
        numTicks: 10
        label: "CPU Load (%)"

        width: 100
        height: 100

        useWarningArea: true
        warnLow: 80.0
        warnHigh: 100.0

        Timer {
            interval: 500
            running: true
            repeat: true

            id: cpu_meter
            property real lastTotal: 0
            property real lastUser:  0

            onTriggered: {
                var doc = new XMLHttpRequest();
                doc.onreadystatechange = function() {
                    if(doc.readyState == XMLHttpRequest.DONE) {
                        var resp = doc.responseText;
                        var lines = resp.split("\n");
                        var cpu_usage = lines[0].replace(/ +/g, ' ').split(' ').map(i => +i);
                        var total =  +cpu_usage[1] + cpu_usage[2] + cpu_usage[3] +
                                cpu_usage[4] + cpu_usage[5] + cpu_usage[6] + cpu_usage[7];
                        var user =  +cpu_usage[1] + cpu_usage[2] + cpu_usage[3];

                        var user_load = 100.0 * (user - cpu_meter.lastUser) / (total - cpu_meter.lastTotal);

                        base_dial.value = user_load;

                        cpu_meter.lastUser = user;
                        cpu_meter.lastTotal = total;
                    }
                }
                doc.open('GET', '/proc/stat');
                doc.send();
            }
        }
    }

    Rectangle {
        width: 100
        height: 100
        color: "blue"
    }

}
