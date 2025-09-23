//
//  EarthNode.swift
//  3d Earth
//
//  Created by Ralph Admin on 10/14/18.
//  Copyright © 2018 IYPC Software. All rights reserved.
//

import GameKit

class EarthNode: SCNNode
{
    override init()
    {
        super.init()
        self.geometry = SCNSphere(radius: 1)
        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Diffuse")
        self.geometry?.firstMaterial?.emission.contents = UIImage(named: "Emission")
        self.geometry?.firstMaterial?.specular.contents = UIImage(named: "Specular")
        self.geometry?.firstMaterial?.normal.contents = UIImage(named: "Normal")
        
        self.geometry?.firstMaterial?.shininess = 50
        
        let angular = GLKMathDegreesToRadians(Float(360))
        let rotateAction = SCNAction.rotate(by: CGFloat(angular), around: SCNVector3Make(0, 1, 0), duration: 7)
        var repeatAction = SCNAction.repeat(rotateAction, count: 2)
        repeatAction = SCNAction.repeatForever(rotateAction)
        self.runAction(repeatAction)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}




