//  GeometryGenerator.swift
//  

import SceneKit
import UIKit

enum PlatonicSolid {
    case tetrahedron
    case octahedron
    case dodecahedron
}

class GeometryGenerator {
    
    // MARK: - Materials
    private var redMaterial: SCNMaterial
    private var darkGrayMaterial: SCNMaterial
    private var blueMaterial: SCNMaterial
    private var wireframeMaterial: SCNMaterial
    
    // MARK: - Init
    init() {
        redMaterial = SCNMaterial()
        redMaterial.lightingModel = .constant
        redMaterial.diffuse.contents = UIColor.red
        
        darkGrayMaterial = SCNMaterial()
        darkGrayMaterial.lightingModel = .constant
        darkGrayMaterial.diffuse.contents = UIColor.systemGray
        
        blueMaterial = SCNMaterial()
        blueMaterial.lightingModel = .constant
        blueMaterial.diffuse.contents = UIColor.systemBlue
        
        wireframeMaterial = SCNMaterial()
        wireframeMaterial.lightingModel = .constant
        wireframeMaterial.diffuse.contents = UIColor.white
        wireframeMaterial.fillMode = .lines
    }
    
    // MARK: - Public API
    func generateSolid(_ type: PlatonicSolid, wireframe: Bool = false) -> SCNNode {
        let geometry: SCNGeometry
        
        switch type {
        case .tetrahedron:
            geometry = generateTetrahedronGeometry()
            geometry.materials = [blueMaterial]
        case .octahedron:
            geometry = generateOctahedronGeometry()
            geometry.materials = [blueMaterial]
        case .dodecahedron:
            geometry = generateDodecahedronGeometry()
            geometry.materials = [blueMaterial]
        }
        
        geometry.firstMaterial?.isDoubleSided = true
        
        // Wireframe toggle
        if wireframe { toggleWireframe(for: geometry, enable: true) }
        
        // Return rotating node
        return rotatingNode(with: geometry)
    }
    
    // MARK: - Geometry Generators
    private func generateTetrahedronGeometry() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(sqrt(8.0/9.0), 0, -1.0/3.0),
            SCNVector3(-sqrt(2.0/9.0), sqrt(2.0/3.0), -1.0/3.0),
            SCNVector3(-sqrt(2.0/9.0), -sqrt(2.0/3.0), -1.0/3.0),
            SCNVector3(0, 0, 1)
        ].map { normalize($0) }
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 0, 3,
            3, 0, 1,
            1, 2, 3
        ]
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    private func generateOctahedronGeometry() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, 0),
            SCNVector3(-0.5, 0, 0.5),
            SCNVector3(0.5, 0, 0.5),
            SCNVector3(0.5, 0, -0.5),
            SCNVector3(-0.5, 0, -0.5),
            SCNVector3(0, -1, 0)
        ].map { normalize($0) }
        
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
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    private func generateDodecahedronGeometry() -> SCNGeometry {
        let phi = (1.0 + sqrt(5.0)) / 2.0
        let a = 1.0
        let b = 1.0 / phi
        let c = phi
        
        let vertices: [SCNVector3] = [
            SCNVector3( a,  a,  a), SCNVector3( a,  a, -a),
            SCNVector3( a, -a,  a), SCNVector3( a, -a, -a),
            SCNVector3(-a,  a,  a), SCNVector3(-a,  a, -a),
            SCNVector3(-a, -a,  a), SCNVector3(-a, -a, -a),
            
            SCNVector3( 0,  b,  c), SCNVector3( 0,  b, -c),
            SCNVector3( 0, -b,  c), SCNVector3( 0, -b, -c),
            
            SCNVector3( b,  c,  0), SCNVector3( b, -c,  0),
            SCNVector3(-b,  c,  0), SCNVector3(-b, -c,  0),
            
            SCNVector3( c,  0,  b), SCNVector3(-c,  0,  b),
            SCNVector3( c,  0, -b), SCNVector3(-c,  0, -b)
        ].map { normalize($0) }
        
        let faces: [[UInt16]] = [
            [0, 8, 10, 2, 16],
            [0, 16, 18, 1, 12],
            [0, 12, 14, 4, 8],
            [8, 4, 17, 6, 10],
            [10, 6, 15, 13, 2],
            [2, 13, 3, 18, 16],
            [1, 9, 11, 3, 18],
            [1, 12, 14, 5, 9],
            [4, 14, 5, 19, 17],
            [6, 17, 19, 7, 15],
            [3, 11, 7, 15, 13],
            [5, 14, 12, 1, 9]
        ]
        
        var indices: [UInt16] = []
        
        // Triangulate pentagons using fan method
        for face in faces {
            for i in 1..<(face.count - 1) {
                indices.append(face[0])
                indices.append(face[i])
                indices.append(face[i + 1])
            }
        }
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    // MARK: - Helpers
    private func rotatingNode(with geometry: SCNGeometry) -> SCNNode {
        let node = SCNNode(geometry: geometry)
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 8))
        node.runAction(rotateAction)
        return node
    }
    
    private func toggleWireframe(for geometry: SCNGeometry, enable: Bool) {
        geometry.firstMaterial?.fillMode = enable ? .lines : .fill
    }
    
    private func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard length > 0 else { return vector }
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }
}
