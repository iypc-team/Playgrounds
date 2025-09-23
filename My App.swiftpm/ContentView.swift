import SwiftUI
import SceneKit
// import QuartzCore
import GLKit

struct SceneKitView : UIViewRepresentable {
    var scene = SCNScene(named: "fighter.scn")!
    //    var scene = SCNScene(named: "smooth_ship.scn")!
    
    func ghostEffect(scene: SCNScene) -> SCNNode {
        // https://stackoverflow.com/questions/43843110/ios-scenekit-add-fresnel-effect-to-material-transparency
        let sphere = SCNSphere(radius: 8)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
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
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.look(at: SCNVector3(0, 0, 0))
        print("cameraNode.orientation ", cameraNode.orientation)
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
        
        let cabinLightNode2 = SCNNode()
        cabinLightNode2.light = SCNLight()
        cabinLightNode2.light!.type = .omni
        cabinLightNode2.light!.color = UIColor.red
        cabinLightNode2.light!.intensity = 10000
        cabinLightNode2.light!.castsShadow = false
        cabinLightNode2.light!.attenuationEndDistance = 4
        cabinLightNode2.position = SCNVector3(x: 0, y: -5.0, z: 0)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.clear
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeMaterial = SCNMaterial()
        planeMaterial.reflective.intensity = .infinity
        print("planeMaterial: ", planeMaterial.diffuse.contents.debugDescription)
        
        let plane = SCNPlane(width: 3, height: 2.2)
        plane.material(named: "planeMaterial")
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(0, -2.55 , 0)
        let radianConversion = CGFloat(GLKMathDegreesToRadians(90.0))
        planeNode.runAction(SCNAction.rotate(by: radianConversion, around: SCNVector3(1, 0, 0), duration: 0))
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "fighter", recursively: true)!
        //        let ship = scene.rootNode.childNode(withName: "enemy", recursively: true)!
        ship.orientation = SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        
        ship.addChildNode(ghostEffect(scene: scene))
        ship.geometry?.firstMaterial?.isDoubleSided = true
        ship.addChildNode(cabinLightNode)
        ship.addChildNode(cabinLightNode)
        ship.addChildNode(engineLightNode)
        ship.addChildNode(engineLightNode2)
        
        let constraint = SCNLookAtConstraint(target: cameraNode)
        constraint.isGimbalLockEnabled = false
        ship.constraints = [constraint]
        
        _ = plane.firstMaterial!.diffuse.contents as Any
        // print(ship)
        // print("plane material\n", planeMaterial.self)
        
        //        SCNTransaction.begin()
        //        SCNTransaction.animationDuration = 1
        //        // let angle = Float(GLKMathDegreesToRadians(22.5))
        //        _ = Float(GLKMathDegreesToRadians(22.5))
        //        
        //        ship.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        //        // cameraNode.eulerAngles = SCNVector3(x: 0.0, y: 0.0, z: Float(radianConversion))
        //        // print("camera.orientation: ", cameraNode.orientation)
        //        SCNTransaction.commit()
        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.allowsCameraControl = true // allows the user to manipulate the camera
        scnView.showsStatistics = true // show statistics such as fps and timing information
        scnView.backgroundColor = UIColor.darkGray // configure the view
        
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
    
    
