// import QtQuick 2.15

// Item {

// }
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

Item {
    id: root
    width: 1280
    height: 480

    function resetCamera() {
        // camera.position = Qt.vector3d(0, 0, 500)
        cameraNode.eulerRotation = Qt.vector3d(0, 0, 0)
    }

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "#CCADA7"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        Node {
            id: cameraNode
            PerspectiveCamera {
                id: camera
                z: 500
                clipNear: 1.0   // Fixes the triangular shadows
                clipFar: 2000.0
            }

            // By putting the light INSIDE the cameraNode,
            // the light follows your eyes. No more dark backsides!

            DirectionalLight {
                id: headlamp
                brightness: 1.5
                eulerRotation.x: -10 // Points slightly down from the camera
            }
        }

        OrbitCameraController {
            origin: cameraNode
            camera: camera
            mouseEnabled: true
            // wheelEnabled: true // This replaces your manual MouseArea wheel logic
            xSpeed: 0.2
            ySpeed: 0.2
        }

        DirectionalLight {
            eulerRotation.x: -30
            brightness: 0.5
            position: Qt.vector3d(-200, 100, 200)
        }

        // PointLight{
        //     color: "#eef5ff"
        //     brightness: 2.0
        //     position: Qt.vector3d(-200, 100, 200)
        // }

        // PointLight{
        //     color: "#ffffff"
        //     brightness: 4.0
        //     position: Qt.vector3d(100, 300, -100)
        // }

        // The Coffee Cup
        Loader3D {
            // id: latte
            // source: "3Dmodel/convert_model/Latte/Latte.qml"
            // scale: Qt.vector3d(200,200,200)

            id: lowpolycoffee
            source: "3Dmodel/convert_model/low_poly_coffee/Low_poly_coffee_cup.qml"
            scale: Qt.vector3d(150,150,150)

            position: Qt.vector3d(20, -50, -20)
            eulerRotation.x: 20
            eulerRotation.y: 0
            eulerRotation.z: 0

        }

        // Orbit controls for Mouse Interaction (replaces mouseMoveEvent)
        // WasdControl {
        //     controlledObject: cameraNode
        // }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            let newZ = camera.z - wheel.angleDelta.y * 0.5
            camera.z = Math.max(100, Math.min(newZ, 1500))
        }
    }

}
