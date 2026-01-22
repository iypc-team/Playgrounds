//  GeometryGenerator.swift
//
//  GeometryGenerator.swift
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

final class GeometryGenerator {
    
    // MARK: - Materials
    
    private let blueMaterial: SCNMaterial = {
        let m = SCNMaterial()
        m.lightingModel = .lambert
        m.diffuse.contents = UIColor.systemBlue
        return m
    }()
    
    private let wireframeMaterial: SCNMaterial = {
        let m = SCNMaterial()
        m.lightingModel = .constant
        m.diffuse.contents = UIColor.white
        m.fillMode = .lines
        return m
    }()
    
    // MARK: - Public API
    
    func generateSolid(_ type: PlatonicSolid, wireframe: Bool = false) -> SCNNode {
        let geometry: SCNGeometry
        
        switch type {
        case .tetrahedron:  geometry = generateTetrahedronGeometry()
        case .cube:         geometry = generateCubeGeometry()
        case .octahedron:   geometry = generateOctahedronGeometry()
        case .dodecahedron: geometry = generateDodecahedronGeometry()
        case .icosahedron:  geometry = generateIcosahedronGeometry()
        }
        
        geometry.materials = [wireframe ? wireframeMaterial : blueMaterial]
        
        return rotatingNode(with: geometry)
    }
    
    // MARK: - Normalization
    
    private func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        return SCNVector3(v.x/len, v.y/len, v.z/len)
    }
    
    private func normalizeVertices(_ vertices: [SCNVector3]) -> [SCNVector3] {
        vertices.map { normalize($0) }
    }
    
    // MARK: - Flat face normals
    
    private func faceNormal(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> SCNVector3 {
        let u = SCNVector3(b.x - a.x, b.y - a.y, b.z - a.z)
        let v = SCNVector3(c.x - a.x, c.y - a.y, c.z - a.z)
        
        let n = SCNVector3(
            u.y * v.z - u.z * v.y,
            u.z * v.x - u.x * v.z,
            u.x * v.y - u.y * v.x
        )
        
        let len = sqrt(n.x*n.x + n.y*n.y + n.z*n.z)
        return SCNVector3(n.x/len, n.y/len, n.z/len)
    }
    
    // MARK: - Shared geometry builder
    
    private func buildFlatShadedGeometry(
        baseVertices: [SCNVector3],
        indices: [UInt16]
    ) -> SCNGeometry {
        
        var vertices: [SCNVector3] = []
        var normals:  [SCNVector3] = []
        
        for i in stride(from: 0, to: indices.count, by: 3) {
            let a = baseVertices[Int(indices[i])]
            let b = baseVertices[Int(indices[i + 1])]
            let c = baseVertices[Int(indices[i + 2])]
            
            let n = faceNormal(a, b, c)
            
            vertices.append(contentsOf: [a, b, c])
            normals.append(contentsOf: [n, n, n])
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        
        let element = SCNGeometryElement(
            indices: Array(0..<UInt16(vertices.count)),
            primitiveType: .triangles
        )
        
        return SCNGeometry(
            sources: [vertexSource, normalSource],
            elements: [element]
        )
    }
    
    // MARK: - Geometry generators
    
    private func generateTetrahedronGeometry() -> SCNGeometry {
        let vertices = normalizeVertices([
            SCNVector3( sqrt(8.0/9.0), 0, -1.0/3.0),
            SCNVector3(-sqrt(2.0/9.0),  sqrt(2.0/3.0), -1.0/3.0),
            SCNVector3(-sqrt(2.0/9.0), -sqrt(2.0/3.0), -1.0/3.0),
            SCNVector3(0, 0, 1)
        ])
        
        let indices: [UInt16] = [
            0,1,2, 2,0,3, 3,0,1, 1,2,3
        ]
        
        return buildFlatShadedGeometry(baseVertices: vertices, indices: indices)
    }
    
    private func generateCubeGeometry() -> SCNGeometry {
        let vertices = normalizeVertices([
            SCNVector3(-0.5,-0.5, 0.5), SCNVector3( 0.5,-0.5, 0.5),
            SCNVector3( 0.5, 0.5, 0.5), SCNVector3(-0.5, 0.5, 0.5),
            SCNVector3(-0.5,-0.5,-0.5), SCNVector3( 0.5,-0.5,-0.5),
            SCNVector3( 0.5, 0.5,-0.5), SCNVector3(-0.5, 0.5,-0.5)
        ])
        
        let indices: [UInt16] = [
            0,1,2, 2,3,0,
            1,5,6, 6,2,1,
            5,4,7, 7,6,5,
            4,0,3, 3,7,4,
            3,2,6, 6,7,3,
            4,5,1, 1,0,4
        ]
        
        return buildFlatShadedGeometry(baseVertices: vertices, indices: indices)
    }
    
    private func generateOctahedronGeometry() -> SCNGeometry {
        let vertices = normalizeVertices([
            SCNVector3(0, 1, 0),
            SCNVector3(-0.5, 0,  0.5),
            SCNVector3( 0.5, 0,  0.5),
            SCNVector3( 0.5, 0, -0.5),
            SCNVector3(-0.5, 0, -0.5),
            SCNVector3(0, -1, 0)
        ])
        
        let indices: [UInt16] = [
            0,1,2, 2,3,0, 3,4,0, 4,1,0,
            1,5,2, 2,5,3, 3,5,4, 4,5,1
        ]
        
        return buildFlatShadedGeometry(baseVertices: vertices, indices: indices)
    }
    
    private func generateDodecahedronGeometry() -> SCNGeometry {
        let phi = (1.0 + sqrt(5.0)) / 2.0
        
        let vertices = normalizeVertices([
            SCNVector3(-1,-1,-1), SCNVector3(-1,-1, 1),
            SCNVector3(-1, 1,-1), SCNVector3(-1, 1, 1),
            SCNVector3( 1,-1,-1), SCNVector3( 1,-1, 1),
            SCNVector3( 1, 1,-1), SCNVector3( 1, 1, 1),
            SCNVector3(0,-1/phi,-phi), SCNVector3(0,-1/phi, phi),
            SCNVector3(0, 1/phi,-phi), SCNVector3(0, 1/phi, phi),
            SCNVector3(-1/phi,-phi,0), SCNVector3(-1/phi, phi,0),
            SCNVector3( 1/phi,-phi,0), SCNVector3( 1/phi, phi,0),
            SCNVector3(-phi,0,-1/phi), SCNVector3( phi,0,-1/phi),
            SCNVector3(-phi,0, 1/phi), SCNVector3( phi,0, 1/phi)
        ])
        
        let faces: [[UInt16]] = [
            [0,8,10,2,16], [0,16,18,1,12], [0,12,14,4,8],
            [8,4,17,6,10], [10,6,15,3,2], [2,3,13,18,16],
            [1,18,13,11,9], [1,9,5,14,12], [4,14,5,17,8],
            [5,9,19,7,17], [6,17,7,15,10], [3,15,7,19,13]
        ]
        
        var indices: [UInt16] = []
        for f in faces {
            indices += [f[0],f[2],f[1], f[0],f[3],f[2], f[0],f[4],f[3]]
        }
        
        return buildFlatShadedGeometry(baseVertices: vertices, indices: indices)
    }
    
    private func generateIcosahedronGeometry() -> SCNGeometry {
        let phi = (1.0 + sqrt(5.0)) / 2.0
        let a = 1.0
        let b = 1.0 / phi
        
        let vertices = normalizeVertices([
            SCNVector3( 0, b,-a), SCNVector3( b, a, 0),
            SCNVector3(-b, a, 0), SCNVector3( 0, b, a),
            SCNVector3( 0,-b, a), SCNVector3(-a, 0, b),
            SCNVector3( 0,-b,-a), SCNVector3( a, 0,-b),
            SCNVector3( a, 0, b), SCNVector3(-a, 0,-b),
            SCNVector3( b,-a, 0), SCNVector3(-b,-a, 0)
        ])
        
        let indices: [UInt16] = [
            0,1,2, 3,2,1, 3,4,5, 3,8,4, 0,6,7,
            0,9,6, 4,10,11, 6,11,10, 2,5,9, 11,9,5,
            1,7,8, 10,8,7, 3,5,2, 3,1,8, 0,2,9,
            0,7,1, 6,9,11, 6,10,7, 4,11,5, 4,8,10
        ]
        
        return buildFlatShadedGeometry(baseVertices: vertices, indices: indices)
    }
    
    // MARK: - Helpers
    
    private func rotatingNode(with geometry: SCNGeometry) -> SCNNode {
        let node = SCNNode(geometry: geometry)
        let action = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 8)
        )
        node.runAction(action)
        return node
    }
}
