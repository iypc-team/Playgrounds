
import SwiftUI
import SceneKit
//import RealityKit
import QuartzCore
import GLKit

struct SceneKitView : UIViewRepresentable {
    var scene = SCNScene(named: "fighter.scn")
    
    func ghostEffect(scene: SCNScene) -> SCNNode {
        // https://stackoverflow.com/questions/43843110/ios-scenekit-add-fresnel-effect-to-material-transparency
        let sphere = SCNSphere(radius: 8)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        // material.diffuse.contents = UIColor.clear
        material.diffuse.contents = UIColor.black
        material.reflective.contents = UIColor(red: 0, green: 0.764, blue: 1, alpha: 1)
        material.reflective.intensity = 3
        material.transparent.contents = UIColor.black.withAlphaComponent(0.3)
        material.transparencyMode = .default
        material.fresnelExponent = 4
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        
        return sphereNode
    }
    
    func makeUIView(context: Context) -> SCNView {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        cameraNode.camera?.automaticallyAdjustsZRange = true
        scene?.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light!.color = UIColor.gray
        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
        scene?.rootNode.addChildNode(lightNode)
        
        let lightNode2 = SCNNode()
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .omni
        lightNode2.light!.color = UIColor.gray
        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
        scene?.rootNode.addChildNode(lightNode2)
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor(.green)
        engineLightNode.light!.intensity = 10000
        engineLightNode.light!.castsShadow = false
        engineLightNode.light!.attenuationEndDistance = 4
        engineLightNode.position = SCNVector3(x: 0, y: -2, z: 0)
        scene?.rootNode.addChildNode(engineLightNode)
        
        let engineLightNode2 = SCNNode()
        engineLightNode2.light = SCNLight()
        engineLightNode2.light!.type = .omni
        engineLightNode2.light!.color = UIColor(.green)
        engineLightNode2.light!.intensity = 10000
        engineLightNode2.light!.castsShadow = false
        engineLightNode2.light!.attenuationEndDistance = 4
        engineLightNode2.position = SCNVector3(x: 0, y: 1.5, z: 0)
        scene?.rootNode.addChildNode(engineLightNode2)
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.light!.type = .omni
        cabinLightNode.light!.color = UIColor(.red)
        cabinLightNode.light!.intensity = 1000
        cabinLightNode.light!.castsShadow = false
        cabinLightNode.light!.attenuationEndDistance = 4
        cabinLightNode.position = SCNVector3(x: 0, y: 4.5, z: 0)
        scene?.rootNode.addChildNode(cabinLightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
        let plane = SCNPlane(width: 3, height: 2.1)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        plane.firstMaterial?.fresnelExponent = .infinity
        plane.firstMaterial?.isDoubleSided = true 
        
//        let planeNode = SCNNode(geometry: plane)
//        planeNode.position = SCNVector3Make(0, 2.55 , 0)
//        let radianConversion = CGFloat(GLKMathDegreesToRadians(90.0))
//        planeNode.runAction(SCNAction.rotate(by: radianConversion, around: SCNVector3(1, 0, 0), duration: 0))
//        scene.rootNode.addChildNode(planeNode)
        
        // retrieve the ship node
        let ship = scene?.rootNode.childNode(withName: "fighter", recursively: true)
        ship?.addChildNode(cabinLightNode)
        
        print("ship.debugDescription\n\(ship.debugDescription)\n")
        print("ship.description\n\(String(describing: ship?.description))\n")
        
        ship?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 8))) // animate 3d 
        

        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
             /*preferredColorScheme(.dark)*/
    }
}

