// 
//  GeometryGenerator.swift
//  Icosahedron-2

import SceneKit

class GeometryGenerator {
    var redMaterial: SCNMaterial
    var darkGrayMaterial: SCNMaterial
    var blueMaterial: SCNMaterial
    var wireframeMaterial: SCNMaterial
    
    init() {
        redMaterial = SCNMaterial()
        redMaterial.lightingModel = .constant
        redMaterial.diffuse.contents = UIColor.red
        
        darkGrayMaterial = SCNMaterial()
        darkGrayMaterial.lightingModel = .constant
        darkGrayMaterial.diffuse.contents = UIColor.darkGray
        
        blueMaterial = SCNMaterial()
        blueMaterial.lightingModel = .constant
        blueMaterial.diffuse.contents = UIColor.blue
        
        wireframeMaterial = SCNMaterial()
        wireframeMaterial.lightingModel = .constant
        wireframeMaterial.diffuse.contents = UIColor.clear
    }
    
    func generateTetrahedron() -> SCNNode {
        print("generateTetrahedron()")
        let vertices: [SCNVector3] = [
            SCNVector3(sqrt(8/9), 0, -1/3),
            SCNVector3(-sqrt(2/9), sqrt(2/3), -1/3.0),
            SCNVector3(-sqrt(2/9), -sqrt(2/3), -1/3),
            SCNVector3(0, 0, 1)
        ]
        
//        print("tetrahedron edge length: \(sqrt(8/3.0))")
        
        let source = SCNGeometrySource(vertices: vertices)
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 0, 3,
            3, 0, 1,
            1, 2, 3
        ]
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [blueMaterial]
        
        // Fix: Enable double-sided rendering to avoid backface culling issues
        geometry.firstMaterial?.isDoubleSided = true
        
        let tetrahedronNode = SCNNode(geometry: geometry)
        tetrahedronNode.position = SCNVector3Zero
        tetrahedronNode.scale = SCNVector3(1, 1, 1)
        
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
        tetrahedronNode.runAction(rotateAction)
        
        return tetrahedronNode
    }
    
    func generateOctahedron() -> SCNNode {
        print("generateOctahedron()")
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, 0),
            SCNVector3(-0.5, 0, 0.5),
            SCNVector3(0.5, 0, 0.5),
            SCNVector3(0.5, 0, -0.5),
            SCNVector3(-0.5, 0, -0.5),
            SCNVector3(0, -1, 0),
        ]
        
        let source = SCNGeometrySource(vertices: vertices)
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 3, 0,
            3, 4, 0,
            4, 1, 0,
            1, 5, 2,
            2, 5, 3,
            3, 5, 4,
            4, 5, 1
        ]
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [blueMaterial]
        
        // Fix: Enable double-sided rendering to avoid backface culling issues
        geometry.firstMaterial?.isDoubleSided = true
        
        let octahedronNode = SCNNode(geometry: geometry)
        octahedronNode.scale = SCNVector3(1, 1, 1)
        
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
        octahedronNode.runAction(rotateAction)
        
        return octahedronNode
    }
    
    func generateDodecahedron() -> SCNNode {
        print("generateDodecahedron()")
        
        let phi = (1.0 + sqrt(5.0)) / 2.0
        
        // 20 vertices of a regular dodecahedron (centered at origin)
        let vertices: [SCNVector3] = [
            SCNVector3(-1, -1, -1),
            SCNVector3(-1, -1,  1),
            SCNVector3(-1,  1, -1),
            SCNVector3(-1,  1,  1),
            SCNVector3( 1, -1, -1),
            SCNVector3( 1, -1,  1),
            SCNVector3( 1,  1, -1),
            SCNVector3( 1,  1,  1),
            SCNVector3(0, -1/phi, -phi),
            SCNVector3(0, -1/phi,  phi),
            SCNVector3(0,  1/phi, -phi),
            SCNVector3(0,  1/phi,  phi),
            SCNVector3(-1/phi, -phi, 0),
            SCNVector3(-1/phi,  phi, 0),
            SCNVector3( 1/phi, -phi, 0),
            SCNVector3( 1/phi,  phi, 0),
            SCNVector3(-phi, 0, -1/phi),
            SCNVector3( phi, 0, -1/phi),
            SCNVector3(-phi, 0,  1/phi),
            SCNVector3( phi, 0,  1/phi)
        ]
        
        let source = SCNGeometrySource(vertices: vertices)
        
        // 12 pentagonal faces (vertex indices)
        let faces: [[UInt16]] = [
            [0, 8, 10, 2, 16],
            [0, 16, 18, 1, 12],
            [0, 12, 14, 4, 8],
            [8, 4, 17, 6, 10],
            [10, 6, 15, 3, 2],
            [2, 3, 13, 18, 16],
            [1, 18, 13, 11, 9],
            [1, 9, 5, 14, 12],
            [4, 14, 5, 17, 8],
            [5, 9, 19, 7, 17],
            [6, 17, 7, 15, 10],
            [3, 15, 7, 19, 13]
        ]
        
        // Triangulate each pentagon with flipped winding for outward normals
        var indices: [UInt16] = []
        for face in faces {
            print("face: \(face )")
            indices.append(contentsOf: [face[0], face[2], face[1]])
            indices.append(contentsOf: [face[0], face[3], face[2]])
            indices.append(contentsOf: [face[0], face[4], face[3]])
        }
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [blueMaterial]
        geometry.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3Zero
        node.scale = SCNVector3(1, 1, 1)
//        node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8)))
        
        print()
        
        return node
    }
    
}

