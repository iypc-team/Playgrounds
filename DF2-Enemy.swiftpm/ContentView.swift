// DF2-Enemy  12/19/2025-1
import SwiftUI
import SceneKit

struct ScenekitView : UIViewRepresentable {
    let scene = SCNScene(named: "smooth_ship.scn")!
    
    func makeUIView(context: Context) -> SCNView {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 100)
        scene.rootNode.addChildNode(lightNode)
        
        let lightNode2 = SCNNode()
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .omni
        lightNode2.position = SCNVector3(x: 0, y: 0, z: -100)
        scene.rootNode.addChildNode(lightNode2)
        
        let engineLightNode = SCNNode()
        engineLightNode.light = SCNLight()
        engineLightNode.light!.type = .omni
        engineLightNode.light!.color = UIColor.red
        engineLightNode.light!.intensity = 7000*2
        engineLightNode.light!.castsShadow = true
        engineLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // retrieve the ship node
        let enemyShip = scene.rootNode.childNode(withName: "enemy", recursively: true)!
        cameraNode.look(at: enemyShip.position)
        let description = enemyShip.geometry?.material(named: "Exterior")?.diffuse.contents.debugDescription
        enemyShip.geometry?.material(named: "Exterior")?.diffuse.contents = UIColor.black
        enemyShip.geometry?.material(named: "Windows")?.diffuse.contents = UIColor.clear 
        enemyShip.geometry?.material(named: "Engine")?.diffuse.contents = UIColor.cyan
        enemyShip.addChildNode(engineLightNode)
        
        print()
        print(enemyShip.geometry!.materials.startIndex)
        print(enemyShip.geometry!.materials.endIndex)
        print("description:\n"
              , description! as Any)
        print("materials[0]\n", enemyShip.geometry!.materials[0])
        print("materials[1]\n", enemyShip.geometry!.materials[1])
        print("materials[2]\n", enemyShip.geometry!.materials[2])
        print("materials[3]\n", enemyShip.geometry!.materials[3])
        
        
        // animate the 3d object
        let radianConversion = CGFloat(GLKMathDegreesToRadians(45.0))
        print("radianConversion: ",radianConversion)
        
        enemyShip.runAction(SCNAction.rotate(by: radianConversion, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4))
        
        sleep(2)
        
        enemyShip.runAction(SCNAction.rotate(by: radianConversion, around: SCNVector3(x: 0.0, y: 1.0, z: 0.0), duration: 4))
     
//        enemyShip.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 2)))
        
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
        scnView.backgroundColor = UIColor.gray
        
        // other items
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}



struct ScenekitView_Previews : PreviewProvider {
    static var previews: some View {
        ScenekitView()
    }
}
