// 
// Loaded 17 PNG files.

import Foundation
import SceneKit
import UIKit

class SceneViewModel: ObservableObject {
    // Observable property to notify the view of changes
    @Published var sceneModel: SceneModel
    @Published var currentRotationX: Float = 0
    @Published var isRotatingX = false
    @Published var currentRotationY: Float = 0
    @Published var isRotatingY = false
    @Published var currentRotationZ: Float = 0
    @Published var isRotatingZ = false
    
    // New: Observable for PNG file URLs
    @Published var pngFileURLs: [URL] = []
    
    init(sceneName: String) {
        let initialCameraPosition = SCNVector3(x: 0, y: 0, z: 20)
        // Initialize SceneModel
        self.sceneModel = SceneModel(sceneName: sceneName, cameraPosition: initialCameraPosition)
    }
    
    func addLightNode(light: SCNNode) {
        sceneModel.lightNodes.append(light)
        sceneModel.scene?.rootNode.addChildNode(light)
    }
    
    func rotateModelOnXAxis() {
        guard !isRotatingX else { return }
        isRotatingX = true
        Task {
            while currentRotationX < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationX += 22.5
                if currentRotationX >= 360 {
                    currentRotationX = 360
                }
            }
            isRotatingX = false
        }
    }
    
    func rotateModelOnYAxis() {
        guard !isRotatingY else { return }
        isRotatingY = true
        Task {
            while currentRotationY < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationY += 22.5
                if currentRotationY >= 360 {
                    currentRotationY = 360
                }
            }
            isRotatingY = false
        }
    }
    
    func rotateModelOnZAxis() {
        guard !isRotatingZ else { return }
        isRotatingZ = true
        Task {
            while currentRotationZ < 360 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                currentRotationZ += 22.5
                if currentRotationZ >= 360 {
                    currentRotationZ = 360
                }
            }
            isRotatingZ = false
        }
    }
    
    func listPNGFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension == "png" }
            print("PNG files in Documents: \(pngFiles.map { $0.lastPathComponent })")
        } catch {
            print("Error listing files: \(error)")
        }
    }
    
    func deleteAllPNGFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension == "png" }
            for fileURL in pngFiles {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted: \(fileURL.lastPathComponent)")
            }
            print("\nAll PNG files deleted.")
            loadPNGFiles()  // Reload after deletion
        } catch {
            print("Error deleting files: \(error)")
        }
    }
    
    // New: Centralized PNG loading
    func loadPNGFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            pngFileURLs = files.filter { $0.pathExtension == "png" }
            print("\nLoaded \(pngFileURLs.count) PNG files.")
        } catch {
            print("Error loading PNG files: \(error)")
            pngFileURLs = []
        }
    }
    
    public func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            // Calculate the scale to fill the target size (aspect fill)
            let scale = max(targetSize.width / image.size.width, targetSize.height / image.size.height)
            let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            // Calculate the origin to crop the center
            let origin = CGPoint(
                x: (scaledSize.width - targetSize.width) / 2,
                y: (scaledSize.height - targetSize.height) / 2
            )
//            let cropRect = CGRect(origin: origin, size: targetSize)
            
            // Draw the cropped and scaled portion
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
}
