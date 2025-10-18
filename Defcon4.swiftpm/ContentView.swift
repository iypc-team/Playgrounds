//  Defcon4  10/18/2025-1
// 
import SwiftUI
import UIKit
import Dispatch
import SceneKit
import GameKit
import Foundation
import RealityKit

//struct Universe: UIViewRepresentable {
//        typealias UV = Universe
//        var universeScene: SCNScene? = SCNScene(named: "bullshit")
//        var universe: SCNSphere? = SCNNode(geometry: .sphere)
//        var universeNode: SCNNode? = SCNNode.init(geometry: universe)
//        
//        let globe = SCNSphere(radius: 1.0) 
//        let earthTexture = UIImage(named: "earth_texture")
//        let material: SCNMaterial = SCNMaterial()
//        material.diffuse.contents = earthTexture 
//        material.isDoubleSided = true 
//        material.diffuse.wrapS = .repeat 
//        material.diffuse.wrapT = .clamp 
//        globe.firstMaterial = material 
//    }

struct SceneKitView : UIViewRepresentable {
    var universeScene: SCNScene? = SCNScene(named: "universe")
    var scene = SCNScene(named: "fighter.scn")!
    //    let shields = Static.ghostEffect()
    func makeUIView(context: Context) -> SCNView {
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        cameraNode.camera?.wantsHDR = true
        scene.rootNode.addChildNode(cameraNode)
        
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .ambient
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 100)
//        lightNode.light!.intensity = 1000
//        scene.rootNode.addChildNode(lightNode)
//        
//        let lightNode_2 = SCNNode()
//        lightNode_2.light = SCNLight()
//        lightNode_2.light!.type = .ambient
//        lightNode_2.position = SCNVector3(x: 0, y: 0, z: -100)
//        lightNode_2.light!.color = UIColor.darkGray
//        lightNode_2.light!.intensity = 100
//        scene.rootNode.addChildNode(lightNode_2)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.light!.intensity = 10
        scene.rootNode.addChildNode(ambientLightNode)
        
        let shipLightNode = SCNNode()
        shipLightNode.light = SCNLight()
        shipLightNode.light!.type = .omni
        shipLightNode.light!.intensity = 1000
        shipLightNode.light!.color =  UIColor.green
        shipLightNode.light!.type = .omni
        
        // retrieve the shipNode node
        let shipNode: SCNNode? = scene.rootNode.childNode(withName: "fighter.scn", recursively: true)
        shipNode?.addChildNode(shipLightNode)
        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
            .preferredColorScheme(.dark)
    }
}

