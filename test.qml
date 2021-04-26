import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: "base_dial"
    width: 200
    height: 200

    antialiasing: true

    property real minimum: 0.0
    property real maximum: 100.0
    property real tickStep: 20.0

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

            strokeColor: "darkgray"
            strokeWidth: 1.4
            fillColor: "transparent"

            PathSvg {
                function genPathString(min, max, step) {
                    return "M 0 -90 L 0 -98 M -90 0 L -98 0 M 90 0 L 98 0 z";
                }

                Component.onCompleted: {
                    this.path = Qt.binding(function() {
                        return genPathString(
                            base_dial.minimum,
                            base_dial.maximum,
                            base_dial.tickStep)
                        });
                }
            }
        }
    }

    Shape {
        id: "shape_needle"
        z: 2

        property real deflection: -30.0

        SequentialAnimation on deflection {
            loops: Animation.Infinite
            running: true

            NumberAnimation { to: -75.0; duration: 3000; easing.type: Easing.InOutCubic }
            NumberAnimation { to:  75.0; duration: 3000; easing.type: Easing.InOutCubic }
        }

        transform: [
            Rotation { origin.x: 0; origin.y: 0; angle: shape_needle.deflection }
        ]

        ShapePath {
            strokeColor: "black"
            strokeWidth: 0

            id: "path_needle"

            fillColor: "darkgray"

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
