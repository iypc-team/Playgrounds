//  SceneModel.swift

import SceneKit
import Foundation

class SceneModel: ObservableObject {
    @Published var sceneName: String = "newFighter.scn"
    
    // Camera
    var cameraPosition: SCNVector3 = SCNVector3(0, 0, 20)
    
    // Node configuration
    var fighterScale: SCNVector3 = SCNVector3(1, 1, 1)
    
    // Lighting
    var lightIntensity: CGFloat     = 500
    var omniLightIntensity: CGFloat = 500
    var cabinLightColor: UIColor    = .red
    var engineLightColor: UIColor   = .green
    
    // Rendering
    var antialiasingMode: SCNAntialiasingMode = .multisampling2X
    
    // Current scene reference (kept in sync by SceneViewModel)
    private var currentScene: SCNScene?
    
    func setScene(_ scene: SCNScene) {
        currentScene = scene
    }
    
    // MARK: - Node & Geometry Accessors
    
    func listAllNodes() -> [SCNNode] {
        currentScene?.rootNode.childNodes(passingTest: { _, _ in true }) ?? []
    }
    
    func listAllGeometries() -> [SCNGeometry] {
        listAllNodes().compactMap { $0.geometry }
    }
    
    // MARK: - Inspection Reports
    
    func printGeometrySummary() {
        guard currentScene != nil else { print("[printGeometrySummary] No scene set."); return }
        let nodes = listAllNodes()
        let geos  = listAllGeometries()
        print("[printGeometrySummary] '\(sceneName)': \(nodes.count) nodes, \(geos.count) with geometry")
        for (i, g) in geos.enumerated() {
            print("  \(i + 1). \(g.name ?? "Unnamed") — \(type(of: g))")
        }
    }
    
    func generateInspectionReport(for sceneName: String) -> String {
        let nodes = listAllNodes()
        let geos  = listAllGeometries()
        let bbox  = sceneBoundingBox()
        
        var r = "Scene: \(sceneName)\n"
        r += "Total Nodes: \(nodes.count)\n"
        r += "Nodes with Geometry: \(geos.count)\n"
        if let b = bbox {
            r += "Bounding Box: Min(\(b.min.x), \(b.min.y), \(b.min.z))"
            + " Max(\(b.max.x), \(b.max.y), \(b.max.z))\n"
        }
        r += "\nGeometries:\n"
        for (i, g) in geos.enumerated() {
            r += "\(i + 1). \(g.name ?? "Unnamed") — \(type(of: g))\n"
            r += "  Materials (\(g.materials.count)):\n"
            for (mi, m) in g.materials.enumerated() {
                r += "    \(mi + 1). \(m.name ?? "Unnamed")\n"
            }
        }
        return r
    }
    
    func generateMaterialsReport(for sceneName: String) -> String {
        let geos = listAllGeometries()
        var r = "Materials in Scene: \(sceneName)\n"
        var total = 0
        for g in geos {
            r += "\nGeometry: \(g.name ?? "Unnamed")\n"
            if g.materials.isEmpty {
                r += "  No materials\n"
            } else {
                for m in g.materials {
                    total += 1
                    r += "  \(total). \(m.name ?? "Unnamed")\n"
                }
            }
        }
        r += total == 0 ? "No materials found.\n" : "\nTotal Materials: \(total)\n"
        return r
    }
    
    // MARK: - Material Modifiers
    
    func setAllMaterialsDoubleSided() {
        listAllGeometries().flatMap { $0.materials }.forEach { $0.isDoubleSided = true }
        print("[setAllMaterialsDoubleSided] Done.")
    }
    
    func setAllMaterialsVeryReflective() {
        listAllGeometries().flatMap { $0.materials }.forEach {
            $0.lightingModel = .physicallyBased
            $0.metalness.contents = 1.0
            $0.roughness.contents = 0.0
        }
        print("[setAllMaterialsVeryReflective] Done.")
    }
    
    func renameGeometry(at index: Int, to newName: String) {
        let geos = listAllGeometries()
        guard index < geos.count else {
            print("[renameGeometry] Index \(index) out of range.")
            return
        }
        geos[index].name = newName
        print("[renameGeometry] Index \(index) renamed to '\(newName)'.")
    }
    
    // MARK: - Bounding Box
    
    func sceneBoundingBox() -> (min: SCNVector3, max: SCNVector3)? {
        currentScene.map { $0.rootNode.boundingBox }
    }
    
    func createBoundingBoxNode() -> SCNNode? {
        guard let box = sceneBoundingBox() else { return nil }
        let size   = SCNVector3(box.max.x - box.min.x,
                                box.max.y - box.min.y,
                                box.max.z - box.min.z)
        let center = SCNVector3((box.max.x + box.min.x) / 2,
                                (box.max.y + box.min.y) / 2,
                                (box.max.z + box.min.z) / 2)
        print("[createBoundingBoxNode] '\(sceneName)' size: \(size)")
        
        let geo = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y),
                         length: CGFloat(size.z), chamferRadius: 0)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white
        mat.fillMode = .lines
        geo.materials = [mat]
        
        let node = SCNNode(geometry: geo)
        node.name = "boundingBox"
        node.position = center
        return node
    }
}
