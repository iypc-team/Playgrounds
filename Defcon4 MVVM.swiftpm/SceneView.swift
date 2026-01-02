// Updated SceneView.swift
// 

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
    
    var viewModel: SceneViewModel 
    
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
        var snapshot = scnView.snapshot()
//        snapshot = SceneViewModel
        snapshot = resizeImage(image: snapshot, targetSize: CGSize(width: 200, height: 200))
//        print("snapshot.size: \(snapshot.size)")
        
        let filename = "\(axis)_\(Int(rotation))°.png"
        print("FileName: \(filename) ")
//        let filename = "rotation\(axis)_\(Int(rotation)).png"
//        print("FileName: \(filename) ")
        
        let imageToSave: UIImage = snapshot  // your image here
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!  // Get the Documents directory URL
        
        // Create a file URL for the image (e.g., "savedImage.png")
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Convert the image to PNG data (or JPEG if preferred)
        if let imageData = imageToSave.pngData() {
            do {
                // Write the data to the file
                try imageData.write(to: fileURL)
                print("Image saved successfully at: \(fileURL)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        print("func resizeImage()")
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            let scale = max(targetSize.width / image.size.width, targetSize.height / image.size.height)
            let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(
                x: (scaledSize.width - targetSize.width) / 2,
                y: (scaledSize.height - targetSize.height) / 2
            )
//            let cropRect = CGRect(origin: origin, size: targetSize)
            if let cgImage = image.cgImage?.cropping(to: CGRect(
                x: origin.x / scale,
                y: origin.y / scale,
                width: targetSize.width / scale,
                height: targetSize.height / scale
            )) {
                let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                croppedImage.draw(in: CGRect(origin: .zero, size: targetSize))
            }
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
