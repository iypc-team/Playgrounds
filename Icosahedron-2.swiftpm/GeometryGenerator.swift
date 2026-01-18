// 
//  GeometryGenerator.swift
//  Icosahedron-2

import SceneKit

class GeometryGenerator {
    var redMaterial: SCNMaterial
    var darkGrayMaterial: SCNMaterial
    var blueMaterial: SCNMaterial
    
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
    }
    
    func generateTetrahedron() -> SCNNode {
        print("generateTetrahedron()")
        let vertices: [SCNVector3] = [
            SCNVector3(sqrt(8/9), 0, -1/3),
            SCNVector3(-sqrt(2/9), sqrt(2/3), -1/3.0),
            SCNVector3(-sqrt(2/9), -sqrt(2/3), -1/3),
            SCNVector3(0, 0, 1)
        ]
        
        print("tetrahedron edge length: \(sqrt(8/3.0))")
        
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
        
        let tetrahedronNode = SCNNode(geometry: geometry)
        tetrahedronNode.position = SCNVector3Zero
        tetrahedronNode.scale = SCNVector3(1, 1, 1)
        
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
        
        let octahedronNode = SCNNode(geometry: geometry)
        octahedronNode.scale = SCNVector3(1, 1, 1)
        
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
        octahedronNode.runAction(rotateAction)
        
        return octahedronNode
    }
    
    func generateDodecahedron() -> SCNNode {
        print("generateDodecahedron()")
        // Golden ratio
        let phi = (1.0 + sqrt(5.0)) / 2.0
        
        // The 20 vertices of a dodecahedron (centered at origin, unit edges)
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
        
        // Indices for each of the 12 faces, subdivided into triangles
        let indices: [UInt16] = [
            0, 8, 9, 0, 9, 1,
            0, 12, 8, 0, 1, 13,
            0, 13, 12, 1, 9, 11,
            1, 11, 13, 2, 10, 8,
            2, 8, 12, 2, 12, 14,
            2, 14, 10, 3, 11, 9,
            3, 9, 8, 3, 8, 10,
            3, 10, 15, 3, 15, 11,
            4, 14, 12, 4, 12, 13,
            4, 13, 11, 4, 11, 15,
            4, 15, 14, 5, 15, 10,
            5, 10, 14, 5, 14, 15
        ]
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [blueMaterial]
        
        let dodecahedronNode = SCNNode(geometry: geometry)
        dodecahedronNode.position = SCNVector3Zero
        dodecahedronNode.scale = SCNVector3(1, 1, 1)
        
        return dodecahedronNode
    }
    
    // If tap interaction is needed, add handleTap method and integrate into ContentView's SCNView
}
