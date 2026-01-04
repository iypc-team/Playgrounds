// 
//  

import Foundation
import SceneKit
import UIKit

class SceneViewModel: ObservableObject {
    // Constants for rotation, timing, and snapshot settings
    private let rotationStep: Float = 22.5
    private let fullRotationDegrees: Float = 360.0
    private let sleepDurationSeconds: Double = 0.5
    private let snapshotWidth: CGFloat = 200.0
    private let snapshotHeight: CGFloat = 200.0
    
    @Published var sceneModel: SceneModel
    @Published var currentRotationX: Float = 0
    @Published var isRotatingX = false
    @Published var currentRotationY: Float = 0
    @Published var isRotatingY = false
    @Published var currentRotationZ: Float = 0
    @Published var isRotatingZ = false
    @Published var pngFileURLs: [URL] = []
    
    init(sceneName: String) {
        let initialCameraPosition = SCNVector3(x: 0, y: 0, z: 25)
        self.sceneModel = SceneModel(sceneName: sceneName, cameraPosition: initialCameraPosition)
    }
    
    func addLightNode(light: SCNNode) {
        sceneModel.lightNodes.append(light)
        sceneModel.scene?.rootNode.addChildNode(light)
    }
    
    func rotateModelOnXAxis() {
        rotate(on: \.isRotatingX, current: \.currentRotationX)
    }
    
    func rotateModelOnYAxis() {
        rotate(on: \.isRotatingY, current: \.currentRotationY)
    }
    
    func rotateModelOnZAxis() {
        rotate(on: \.isRotatingZ, current: \.currentRotationZ)
    }
    
    private func rotate(on isRotating: ReferenceWritableKeyPath<SceneViewModel, Bool>, current: ReferenceWritableKeyPath<SceneViewModel, Float>) {
        guard !self[keyPath: isRotating] else { return }
        self[keyPath: isRotating] = true
        Task {
            while self[keyPath: current] < fullRotationDegrees {
                try? await Task.sleep(nanoseconds: UInt64(sleepDurationSeconds * 1_000_000_000))
                self[keyPath: current] += rotationStep
                if self[keyPath: current] >= fullRotationDegrees {
                    self[keyPath: current] = fullRotationDegrees
                }
            }
            self[keyPath: isRotating] = false
        }
    }
    
    func captureAndSavePNG(scnView: SCNView, axis: String, rotation: Float) throws {
        var snapshot = scnView.snapshot()
        snapshot = resizeImage(image: snapshot, targetSize: CGSize(width: snapshotWidth, height: snapshotHeight))
        
        let filename = "\(axis)_\(Float(rotation))°.png"
        let imageToSave: UIImage = snapshot
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard let imageData = imageToSave.pngData() else {
            throw NSError(domain: "SceneViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG data"])
        }
        
        try imageData.write(to: fileURL)
    }
    
    func deleteAllPNGFilesAsync() async throws {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        try await Task.detached {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let pngFiles = files.filter { $0.pathExtension == "png" }
            for fileURL in pngFiles {
                try FileManager.default.removeItem(at: fileURL)
            }
        }.value
    }
    
    func loadPNGFilesAsync() async throws -> [URL] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return try await Task.detached {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "png" }
        }.value
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            let scale = max(targetSize.width / image.size.width, targetSize.height / image.size.height)
            let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(
                x: (scaledSize.width - targetSize.width) / 2,
                y: (scaledSize.height - targetSize.height) / 2
            )
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
