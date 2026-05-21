import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: chocolate_Bar_material
        objectName: "Chocolate Bar"
        baseColor: "#ff5e2404"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: cup_material
        objectName: "Cup"
        baseColor: "#ffe7cfaf"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: plate_material
        objectName: "Plate"
        baseColor: "#ffe79f5f"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: water_material
        objectName: "Water"
        baseColor: "#ff5e2404"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }

    // Nodes:
    Node {
        id: chocolate_Drink
        objectName: "Chocolate Drink"
        position: Qt.vector3d(0.000398319, 0.560517, -0.243584)
        Model {
            id: chocolate_Bar
            objectName: "Chocolate Bar"
            position: Qt.vector3d(0.540664, -0.208046, 0.711892)
            source: "meshes/cube_051_mesh.mesh"
            materials: [
                chocolate_Bar_material
            ]
        }
        Model {
            id: cup
            objectName: "Cup"
            position: Qt.vector3d(0.0297141, 0.0662914, -0.0543895)
            source: "meshes/cylinder_028_mesh.mesh"
            materials: [
                cup_material
            ]
        }
        Model {
            id: plate
            objectName: "Plate"
            position: Qt.vector3d(-0.000637742, -0.461392, 0.158991)
            source: "meshes/cylinder_029_mesh.mesh"
            materials: [
                plate_material
            ]
        }
        Model {
            id: water
            objectName: "Water"
            position: Qt.vector3d(-0.0816865, 0.318151, 0.00178958)
            source: "meshes/cube_050_mesh.mesh"
            materials: [
                water_material
            ]
        }
    }

    // Animations:
}
