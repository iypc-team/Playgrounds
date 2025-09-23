////
////  FighterNode.swift
////  3d Earth
////
////  Created by Ralph Admin on 10/20/18.
////  Copyright © 2018 IYPC Software. All rights reserved.
////
//
//import GameKit
//
//class FighterNode: SCNNode
//{
//    var fighterScene: SCNScene!
//    
//    override init()
//    {
//        super.init()
//        
//        fighterScene =  SCNScene(named: "art.scnassets/fighterPBR.scn")!
//        self.geometry = fighterScene.rootNode.childNode(withName: "fighter", recursively: true)!.geometry
//        
//        self.geometry?.firstMaterial?.shininess = 50
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//}
