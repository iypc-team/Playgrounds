//  GeometryGenerator.swift
//  Refactored by Code GPT 🧠
//

import SceneKit
import UIKit

enum PlatonicSolid {
    case tetrahedron
    case cube
    case octahedron
    case dodecahedron
    case icosahedron
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
        case .cube:
            geometry = generateCubeGeometry()
            geometry.materials = [blueMaterial]
        case .octahedron:
            geometry = generateOctahedronGeometry()
            geometry.materials = [blueMaterial]
        case .dodecahedron:
            geometry = generateDodecahedronGeometry()
            geometry.materials = [blueMaterial]
        case .icosahedron: 
            geometry = generateIcosahedronGeometry()
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
        ]
        
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
    
    private func generateCubeGeometry() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            // Front
            SCNVector3(-0.5, -0.5,  0.5),
            SCNVector3( 0.5, -0.5,  0.5),
            SCNVector3( 0.5,  0.5,  0.5),
            SCNVector3(-0.5,  0.5,  0.5),
            // Back
            SCNVector3(-0.5, -0.5, -0.5),
            SCNVector3( 0.5, -0.5, -0.5),
            SCNVector3( 0.5,  0.5, -0.5),
            SCNVector3(-0.5,  0.5, -0.5)
        ]
        
        let indices: [UInt16] = [
            // Front
            0, 1, 2,  2, 3, 0,
            // Right
            1, 5, 6,  6, 2, 1,
            // Back
            5, 4, 7,  7, 6, 5,
            // Left
            4, 0, 3,  3, 7, 4,
            // Top
            3, 2, 6,  6, 7, 3,
            // Bottom
            4, 5, 1,  1, 0, 4
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
        ]
        
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
        
        var indices: [UInt16] = []
        for face in faces {
            indices.append(contentsOf: [face[0], face[2], face[1]])
            indices.append(contentsOf: [face[0], face[3], face[2]])
            indices.append(contentsOf: [face[0], face[4], face[3]])
        }
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    private func generateIcosahedronGeometry() -> SCNGeometry {
        let phi = (1.0 + sqrt(5.0)) / 2.0
        let a = 1.0
        let b = 1.0 / phi
        
        let vertices: [SCNVector3] = [
            SCNVector3( 0,  b, -a), SCNVector3( b,  a,  0),
            SCNVector3(-b,  a,  0), SCNVector3( 0,  b,  a),
            SCNVector3( 0, -b,  a), SCNVector3(-a,  0,  b),
            SCNVector3( 0, -b, -a), SCNVector3( a,  0, -b),
            SCNVector3( a,  0,  b), SCNVector3(-a,  0, -b),
            SCNVector3( b, -a,  0), SCNVector3(-b, -a,  0)
        ]
        
        let indices: [UInt16] = [
            0,1,2,  3,2,1,  3,4,5,  3,8,4,  0,6,7,
            0,9,6,  4,10,11, 6,11,10, 2,5,9, 11,9,5,
            1,7,8, 10,8,7,  3,5,2,  3,1,8,  0,2,9,
            0,7,1,  6,9,11, 6,10,7,  4,11,5,  4,8,10
        ]
        
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
}
