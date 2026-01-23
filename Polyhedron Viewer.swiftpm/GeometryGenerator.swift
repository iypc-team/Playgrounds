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
        
        geometry.materials = [
            (wireframe ? wireframeMaterial : blueMaterial).copy() as! SCNMaterial
        ]
        
        return node(with: geometry)
    }
    
    // MARK: - Helpers
    
    private func angleAroundAxis(
        v: SCNVector3,
        center: SCNVector3,
        ref: SCNVector3,
        axis: SCNVector3
    ) -> Float {
        
        let px = v.x - center.x
        let py = v.y - center.y
        let pz = v.z - center.z
        
        let dot = ref.x * px + ref.y * py + ref.z * pz
        
        let cx = ref.y * pz - ref.z * py
        let cy = ref.z * px - ref.x * pz
        let cz = ref.x * py - ref.y * px
        
        let det = axis.x * cx + axis.y * cy + axis.z * cz
        return atan2(det, dot)
    }
    
    private func node(with geometry: SCNGeometry) -> SCNNode {
        return SCNNode(geometry: geometry)
    }
    
    // MARK: - Math utilities
    
    private func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        return SCNVector3(v.x/len, v.y/len, v.z/len)
    }
    
    private func normalizeVertices(_ vertices: [SCNVector3]) -> [SCNVector3] {
        vertices.map { normalize($0) }
    }
    
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
    
    // MARK: - Geometry builder
    
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
    
    // MARK: - Solid generators
    // (unchanged geometry math below)
    
    private func generateTetrahedronGeometry() -> SCNGeometry {
        let vertices = normalizeVertices([
            SCNVector3( 1,  1,  1),
            SCNVector3(-1, -1,  1),
            SCNVector3(-1,  1, -1),
            SCNVector3( 1, -1, -1)
        ])
        
        let indices: [UInt16] = [
            0,2,1, 0,1,3, 0,3,2, 1,2,3
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
        
        let phi: Float = (1.0 + sqrt(5.0)) / 2.0
        let a: Float = 1.0
        let b: Float = 1.0 / phi
        
        // ---- Icosahedron vertices ----
        let icoVertices: [SCNVector3] = normalizeVertices([
            SCNVector3( 0,  b, -a), SCNVector3( b,  a,  0),
            SCNVector3(-b,  a,  0), SCNVector3( 0,  b,  a),
            SCNVector3( 0, -b,  a), SCNVector3(-a,  0,  b),
            SCNVector3( 0, -b, -a), SCNVector3( a,  0, -b),
            SCNVector3( a,  0,  b), SCNVector3(-a,  0, -b),
            SCNVector3( b, -a,  0), SCNVector3(-b, -a,  0)
        ])
        
        let icoFaces: [[Int]] = [
            [0,1,2],[3,2,1],[3,4,5],[3,8,4],[0,6,7],
            [0,9,6],[4,10,11],[6,11,10],[2,5,9],[11,9,5],
            [1,7,8],[10,8,7],[3,5,2],[3,1,8],[0,2,9],
            [0,7,1],[6,9,11],[6,10,7],[4,11,5],[4,8,10]
        ]
        
        // ---- Dodecahedron vertices = face centers ----
        var dodecaVertices: [SCNVector3] = []
        dodecaVertices.reserveCapacity(icoFaces.count)
        
        for face in icoFaces {
            let v0 = icoVertices[face[0]]
            let v1 = icoVertices[face[1]]
            let v2 = icoVertices[face[2]]
            
            let cx = (v0.x + v1.x + v2.x) / 3.0
            let cy = (v0.y + v1.y + v2.y) / 3.0
            let cz = (v0.z + v1.z + v2.z) / 3.0
            
            dodecaVertices.append(normalize(SCNVector3(cx, cy, cz)))
        }
        
        // ---- Build adjacency (each ico vertex → 5 faces) ----
        var facesAtVertex: [[Int]] = Array(repeating: [], count: icoVertices.count)
        for i in 0..<icoFaces.count {
            let f = icoFaces[i]
            facesAtVertex[f[0]].append(i)
            facesAtVertex[f[1]].append(i)
            facesAtVertex[f[2]].append(i)
        }
        
        var indices: [UInt16] = []
        
        // ---- Build pentagons with angle sorting ----
        for faceList in facesAtVertex {
            
            // Compute face center
            var cx: Float = 0
            var cy: Float = 0
            var cz: Float = 0
            
            for idx in faceList {
                let v = dodecaVertices[idx]
                cx += v.x
                cy += v.y
                cz += v.z
            }
            
            let count = Float(faceList.count)
            let center = SCNVector3(cx / count, cy / count, cz / count)
            let normal = normalize(center)
            
            let ref = normalize(SCNVector3(
                dodecaVertices[faceList[0]].x - center.x,
                dodecaVertices[faceList[0]].y - center.y,
                dodecaVertices[faceList[0]].z - center.z
            ))
            
            let sorted = faceList.sorted { i0, i1 in
                let v0 = dodecaVertices[i0]
                let v1 = dodecaVertices[i1]
                
                let a0 = angleAroundAxis(v: v0, center: center, ref: ref, axis: normal)
                let a1 = angleAroundAxis(v: v1, center: center, ref: ref, axis: normal)
                return a0 < a1
            }
            
            // Fan triangulation
            for i in 1..<(sorted.count - 1) {
                indices.append(UInt16(sorted[0]))
                indices.append(UInt16(sorted[i]))
                indices.append(UInt16(sorted[i + 1]))
            }
        }
        
        return buildFlatShadedGeometry(
            baseVertices: dodecaVertices,
            indices: indices
        )
    }
    
    private func generateIcosahedronGeometry() -> SCNGeometry {
        // unchanged — same math as your original
        fatalError("Use your existing implementation here (no rotation changes needed)")
    }
}
