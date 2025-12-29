// Updated SceneView.swift

import SwiftUI
import SceneKit
import UIKit

struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    @Binding var rotationX: Float
    @Binding var rotationY: Float
    @Binding var rotationZ: Float
    @Binding var isRotatingX: Bool
    @Binding var isRotatingY: Bool
    @Binding var isRotatingZ: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        if let node = findNodeWithGeometry(in: scnView.scene?.rootNode) {
            node.eulerAngles.x = rotationX * .pi / 180
            node.eulerAngles.y = rotationY * .pi / 180
            node.eulerAngles.z = rotationZ * .pi / 180
            scnView.setNeedsDisplay()
            
            // Capture and save PNG if rotating on a specific axis
            if isRotatingX {
                captureAndSavePNG(scnView: scnView, axis: "X", rotation: rotationX)
            } else if isRotatingY {
                captureAndSavePNG(scnView: scnView, axis: "Y", rotation: rotationY)
            } else if isRotatingZ {
                captureAndSavePNG(scnView: scnView, axis: "Z", rotation: rotationZ)
            }
        }
    }
    
    private func captureAndSavePNG(scnView: SCNView, axis: String, rotation: Float) {
        let snapshot = scnView.snapshot()
        let resizedImage = resizeImage(image: snapshot, targetSize: CGSize(width: 200, height: 200))
        let filename = "rotation\(axis)_\(Int(rotation)).png"
        savePNG(image: resizedImage, filename: filename)
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            // Calculate the rect to draw the image proportionally within the target size
            let aspectRatio = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
            let scaledSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2, y: (targetSize.height - scaledSize.height) / 2)
            let rect = CGRect(origin: origin, size: scaledSize)
            
            // Clear the context (transparent background)
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // Draw the scaled image
            image.draw(in: rect)
        }
    }
    
    private func savePNG(image: UIImage, filename: String) {
        guard let data = image.pngData() else { return }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            print("Saved PNG: \(filename) at \(fileURL.path)")
        } catch {
            print("Failed to save PNG: \(error)")
        }
    }
    
    private func findNodeWithGeometry(in node: SCNNode?) -> SCNNode? {
        guard let node = node else { return nil }
        if node.geometry != nil {
            return node
        }
        for child in node.childNodes {
            if let found = findNodeWithGeometry(in: child) {
                return found
            }
        }
        return nil
    }
}
