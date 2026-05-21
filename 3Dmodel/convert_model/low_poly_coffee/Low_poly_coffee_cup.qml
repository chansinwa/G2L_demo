import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    property url textureData: "maps/textureData.png"
    Texture {
        id: _0_texture
        magFilter: Texture.Nearest
        minFilter: Texture.Nearest
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData
    }
    PrincipledMaterial {
        id: porcelain_material
        objectName: "Porcelain"
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        // cullMode: PrincipledMaterial.BackFaceCulling
        alphaMode: PrincipledMaterial.Opaque
        // lighting: PrincipledMaterial.NoLighting
        baseColor: "#cccccc"
    }
    PrincipledMaterial {
        id: coffee_material
        objectName: "Coffee"
        baseColorMap: _0_texture
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
        lighting: PrincipledMaterial.NoLighting
    }

    // Nodes:
    Node {
        id: sketchfab_model
        objectName: "Sketchfab_model"
        rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
        Node {
            id: root
            objectName: "Root"
            Node {
                id: lamp
                objectName: "Lamp"
                position: Qt.vector3d(4.07625, 1.00545, 5.90386)
                rotation: Qt.quaternion(0.570949, 0.169074, 0.272171, 0.75588)
                scale: Qt.vector3d(0.999998, 0.999996, 0.999996)
                Node {
                    id: lamp4
                    objectName: "Lamp"
                }
            }
            Node {
                id: cylinder
                objectName: "Cylinder"
                position: Qt.vector3d(0.39137, 0, 0)
                rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
                Model {
                    id: cylinder_0
                    objectName: "Cylinder_0"
                    source: "meshes/cylinder_0_mesh.mesh"
                    materials: [
                        porcelain_material
                    ]
                }
                Model {
                    id: cylinder_1
                    objectName: "Cylinder_1"
                    source: "meshes/cylinder_1_mesh.mesh"
                    materials: [
                        coffee_material
                    ]
                }
            }
        }
    }

    // Animations:
}
