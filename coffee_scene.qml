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
        camera.position = Qt.vector3d(0, 0, 500)
        cameraNode.eulerRotation = Qt.vector3d(0, 0, 0)
    }

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "#00FFFF" // Cyan like your TGX code
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
        }

        DirectionalLight {
            eulerRotation.x: -30
            brightness: 1.0
        }

        // The Coffee Cup
        Model {
            id: coffeeCup
            source: "media/coffee_cup.mesh" // You need to export your model to .mesh
            scale: Qt.vector3d(10, 10, 10)
            materials: [
                DefaultMaterial {
                    diffuseColor: "white"
                    specularAmount: 1.0
                    shininess: 100
                }
            ]
        }

        // Orbit controls for Mouse Interaction (replaces mouseMoveEvent)
        WasdControl {
            controlledObject: cameraNode
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            camera.z -= wheel.angleDelta.y * 0.5
        }
    }
}
