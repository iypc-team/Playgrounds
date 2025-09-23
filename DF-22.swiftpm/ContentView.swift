
import SwiftUI
import SceneKit
import QuartzCore
import GLKit

struct SceneKitView : UIViewRepresentable {
    var scene = SCNScene(named: "fighter.scn")!
//    var scene = SCNScene(named: "smooth_ship.scn")!
    
    func makeUIView(context: Context) -> SCNView {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
//        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.look(at: SCNVector3(0, 0, 0))
        // print("cameraNode.orientation ", cameraNode.orientation)
        scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.light!.color = UIColor.clear
        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
        scene.rootNode.addChildNode(lightNode)
        
        let lightNode2 = SCNNode()
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .ambient
        lightNode2.light!.color = UIColor.clear
        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
        scene.rootNode.addChildNode(lightNode2)
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor.green
        engineLightNode.light!.intensity = 10000
        engineLightNode.light!.castsShadow = false
        engineLightNode.light!.attenuationEndDistance = 4
        engineLightNode.position = SCNVector3(x: 0, y: -2, z: 0)
        
        let engineLightNode2 = SCNNode()
        engineLightNode2.light = SCNLight()
        engineLightNode2.light!.type = .omni
        engineLightNode2.light!.color = UIColor.green
        engineLightNode2.light!.intensity = 10000
        engineLightNode2.light!.castsShadow = false
        engineLightNode2.light!.attenuationEndDistance = 4
        engineLightNode2.position = SCNVector3(x: 0, y: 1.5, z: 0)
        
        let cabinLightNode = SCNNode()
        cabinLightNode.light = SCNLight()
        cabinLightNode.light!.type = .omni
        cabinLightNode.light!.color = UIColor.red
        cabinLightNode.light!.intensity = 10000
        cabinLightNode.light!.castsShadow = false
        cabinLightNode.light!.attenuationEndDistance = 4
        cabinLightNode.position = SCNVector3(x: 0, y: -5.0, z: 0)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.clear
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeMaterial = SCNMaterial()
        print("planeMaterial: ", planeMaterial.diffuse.contents.debugDescription)
        
        let plane = SCNPlane(width: 3, height: 2.2)
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        plane.firstMaterial?.fresnelExponent = .infinity
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(0, -2.55 , 0)
        let radianConversion = CGFloat(GLKMathDegreesToRadians(90.0))
        planeNode.runAction(SCNAction.rotate(by: radianConversion, around: SCNVector3(1, 0, 0), duration: 0))
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "fighter", recursively: true)!
//        let ship = scene.rootNode.childNode(withName: "enemy", recursively: true)!
        ship.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
    
        ship.geometry?.firstMaterial?.isDoubleSided = true
        
        // ship.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        ship.addChildNode(planeNode)
        ship.addChildNode(cabinLightNode)
        ship.addChildNode(engineLightNode)
        ship.addChildNode(engineLightNode2)
        
        // cameraConstraint.target = ship
        
        print("\nship.pivot\n", ship.pivot)
        // print("ship.orientation\n", ship.orientation!)
        _ = plane.firstMaterial!.diffuse.contents as Any
        // print(ship)
        // print("plane material\n", planeMaterial.self)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        // let angle = Float(GLKMathDegreesToRadians(22.5))
        _ = Float(GLKMathDegreesToRadians(22.5))
        
        ship.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        // cameraNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: Float(radianConversion))
        // print("camera.orientation: ", cameraNode.orientation)
        SCNTransaction.commit()
        
        print("ship.orientation: ", ship.orientation)
        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        // configure the view
        scnView.backgroundColor = UIColor.darkGray
        
        // other items
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}



struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
            .preferredColorScheme(.dark)
    }
}
