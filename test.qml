import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: "base_dial"
    width: 200
    height: 200

    antialiasing: true

    property real minimum: 0.0
    property real maximum: 100.0
    property int numTicks: 8

    readonly property real g_zero_scale: -130.0
    readonly property real g_full_scale:  130.0

    // The face metrics are based around a geometry from (-100, -100) to (100,
    // 100), with the center at (0, 0)
    transform: [
        Translate {
            x: 100
            y: 100
        },
        Scale {
            origin.x: 0
            origin.y: 0
            xScale: 2
            yScale: 2
        }
    ]

    Rectangle {
        x: -100
        y: -100
        width: 200
        height: 200
        z: 0

        gradient: Gradient {
            GradientStop { position: 0; color: "#4B4B4B" }
            GradientStop { position: 1; color: "#232323" }
        }

        border.color: "black"
        border.width: 0
        radius: 15
        antialiasing: true
    }

    Shape {
        z: 1
        id: "shape_back_face"

        ShapePath {
            id: "shape_back_outer_ring"

            strokeColor: "black"
            strokeWidth: 0.5
            fillColor: "white"

            startX: 0
            startY: -98

            PathArc {
                x: -98
                y: 0
                radiusX: 98
                radiusY: 98
                useLargeArc: true
            }

            PathArc {
                x: 0
                y: -98
                radiusX: 98
                radiusY: 98
                useLargeArc: false
            }
        }

        ShapePath {
            id: "shape_back_tick_marks"

            strokeColor: "black"
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathSvg {
                function genPathString(min, max, numTicks) {
                    if(numTicks < 2 || (Math.abs(max - min) < Number.EPSILON))
                        return "z";

                    // tickStep in terms of displayed input
                    var tickStep = (max - min) / numTicks;

                    // Where the marker line starts and ends with no rotation
                    // applied
                    const markStart = Qt.vector3d(0.0, -98, 0);
                    const markEnd   = Qt.vector3d(0.0, -90, 0);

                    // start to end deflection in radians
                    var radFullDefl = ((g_full_scale - g_zero_scale) * Math.PI / 180.0);
                    var radStep = radFullDefl / numTicks;
                    var radStart = -radFullDefl / 2; // we're centered around 0
                    var radEnd = radFullDefl / 2;

                    // the SVG path string
                    var svgString = "";

                    var x = radStart; // the loop var

                    while(x <= radEnd) {
                        // Get new rotation matrix and modify our vector

                        var rotMatrix = Qt.matrix4x4(
                            Math.cos(x), -Math.sin(x), 0, 0,
                            Math.sin(x),  Math.cos(x), 0, 0,
                            0          ,  0          , 1, 0,
                            0          ,  0          , 0, 1
                            );

                        var pathStart = rotMatrix.times(markStart);
                        var pathEnd   = rotMatrix.times(markEnd);

                        svgString += "M " + pathStart.x.toFixed(1) + " " + pathStart.y.toFixed(1);
                        svgString += "L " + pathEnd.x.toFixed(1)   + " " + pathEnd.y.toFixed(1) + " ";

                        x += radStep;
                    }

                    svgString += "z";
                    return svgString;
                }

                Component.onCompleted: {
                    this.path = Qt.binding(function() {
                        return genPathString(
                            base_dial.minimum,
                            base_dial.maximum,
                            base_dial.numTicks)
                        });
                }
            }
        }

        ShapePath {
            id: "shape_back_inner_ring"

            strokeColor: "darkgray"
            strokeWidth: 0.5
            fillColor: "transparent"

            startX: 90 * Math.sin(Math.PI * base_dial.g_zero_scale / 180.0)
            startY: -90 * Math.cos(Math.PI * base_dial.g_zero_scale / 180.0)

            PathArc {
                x: -shape_back_inner_ring.startX
                y:  shape_back_inner_ring.startY
                radiusX: 90
                radiusY: 90
                useLargeArc: true
            }
        }

        ShapePath {
            id: "shape_back_label_base"

            strokeColor: "black"
            strokeWidth: 1.0
            fillColor: "white"

            startX: -73
            startY: 72

            PathCubic {
                x: -19; y: 44
                control1X: -52; control1Y: 55;
                control2X: -38; control2Y: 48;
            }

            PathMove {
                x: 19; y: 44
            }

            PathCubic {
                x: 73; y: 72
                control1X: 38; control1Y: 48;
                control2X: 52; control2Y: 55;
            }
        }
    }

    Shape {
        id: "shape_needle"
        z: 2

        // Full zero deflection (far left) is -130.0
        // Full max deflection (far right) is 130.0
        // Half-way deflection (middle) is 0.0
        property real deflection: -30.0

        SequentialAnimation on deflection {
            loops: Animation.Infinite
            running: true

            NumberAnimation { to: -130.0; duration: 3000; easing.type: Easing.InOutCubic }
            NumberAnimation { to:  130.0; duration: 3000; easing.type: Easing.InOutCubic }
        }

        transform: [
            Rotation { origin.x: 0; origin.y: 0; angle: shape_needle.deflection }
        ]

        ShapePath {
            strokeColor: "darkgray"
            strokeWidth: 0

            id: "path_needle"

            fillColor: "#323232"

            startX: 10
            startY: -5

            PathCubic {
                x: 5; y: -69
                control1X: 3; control1Y: -18;
                control2X: 2; control2Y: -57;
            }

            PathCubic {
                x: 0; y: -90
                control1X: 2; control1Y: -77;
                control2X: 1; control2Y: -80;
            }

            PathCubic {
                x: -5; y: -69
                control1X: -1; control1Y: -80;
                control2X: -2; control2Y: -77;
            }

            PathCubic {
                x: -10; y: -5
                control1X: -2; control1Y: -57;
                control2X: -3; control2Y: -18;
            }

            PathLine { x: 10; y: -5 }
        }

        ShapePath {
            strokeColor: "darkgray"
            strokeWidth: 0.4

            startX: 0
            startY: 0

            PathLine { x: 0; y: -84 }
        }
    }

    Shape {
        z: 3
        id: "path_needle_cover"

        ShapePath {
            strokeColor: "black"
            strokeWidth: 0

            fillColor: "white"

            startX: -19
            startY: 44

            PathLine { x: -27; y: 8 }

            PathCubic {
                x: 27; y: 8
                control1X: -33; control1Y: -37;
                control2X:  33; control2Y: -37;
            }

            PathLine { x: 19; y: 44 }
        }
    }
}
