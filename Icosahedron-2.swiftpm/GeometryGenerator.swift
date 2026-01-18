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
    
    // If tap interaction is needed, add handleTap method and integrate into ContentView's SCNView
}
