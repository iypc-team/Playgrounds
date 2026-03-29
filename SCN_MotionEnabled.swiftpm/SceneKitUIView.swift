//  SceneKitUIView.swift
//  

import SwiftUI
import SceneKit

struct SceneKitUIView: UIViewControllerRepresentable {
    var combatScene: SCNScene
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let scnView = SCNView(frame: viewController.view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scnView.scene = combatScene
        scnView.allowsCameraControl = true
        scnView.isUserInteractionEnabled = true
        viewController.view.addSubview(scnView)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let scnView = uiViewController.view.subviews.first as? SCNView {
            scnView.scene = combatScene
            // Ensure the point of view is set to the camera node if present
            if let cameraNode = scnView.scene?.rootNode.childNodes.first(where: { $0.camera != nil }) {
                scnView.pointOfView = cameraNode
            }
            // Configure the view for better rendering
            scnView.allowsCameraControl = true
            scnView.showsStatistics = true
            scnView.backgroundColor = UIColor.darkGray
            scnView.antialiasingMode = .multisampling4X
            scnView.autoenablesDefaultLighting = true
            scnView.isTemporalAntialiasingEnabled = true
        }
    }
}
