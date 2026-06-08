// DocumentManager.swift

import Foundation
import SwiftUI
import SceneKit
import UniformTypeIdentifiers

@MainActor
class DocumentManager: ObservableObject {
    
    @Published var scene: SCNScene?
    @Published var isLoading    = false
    @Published var isSaving     = false
    @Published var isConverting = false
    @Published var fileMetadata: FileMetadata?
    @Published var errorMessage: String?
    
    // MARK: - Load File
    func loadFile(from url: URL) async throws {
        guard url.pathExtension.lowercased() == "scn" else {
            throw NSError(
                domain: "SKEditError", code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Only .scn files can be opened"]
            )
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        await updateMetadata(for: url)
        try await downloadIfNeeded(url)
        let loadedScene = try await loadScene(from: url)
        applyPreLoadRotation(to: loadedScene, filename: url.lastPathComponent) // ← NEW
        self.scene = loadedScene
    }
    
    private func loadScene(from url: URL) async throws -> SCNScene {
        try await Task.detached {
            try SCNScene(url: url, options: nil)
        }.value
    }
    
    // MARK: - Pre-load Transform
    /// Rotates each top-level child node of `smooth_ship.scn` by π/2 radians
    /// about the x-axis by pre-multiplying its simdTransform with a
    /// quaternion-derived rotation matrix — before the scene is assigned to
    /// self.scene. No eulerAngles, no intermediate pivot node.
    private func applyPreLoadRotation(to scene: SCNScene, filename: String) {
        guard filename.lowercased() == "smooth_ship.scn" else { return }
        
        let rotation = simd_quatf(angle: .pi / 2.0, axis: SIMD3<Float>(1, 0, 0))
        let rotMatrix = simd_float4x4(rotation)
        
        scene.rootNode.childNodes.forEach { node in
            node.simdTransform = rotMatrix * node.simdTransform
        }
    }
    
    // MARK: - Save File
    func saveFile(to url: URL) async throws {
        guard url.pathExtension.lowercased() == "scn" else {
            throw NSError(
                domain: "SKEditError", code: 5,
                userInfo: [NSLocalizedDescriptionKey: "Only .scn files can be saved"]
            )
        }
        guard let sceneToSave = self.scene else {
            throw NSError(
                domain: "SKEditError", code: 6,
                userInfo: [NSLocalizedDescriptionKey: "No scene loaded to save"]
            )
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var coordinationError: NSError?
            
            coordinator.coordinate(
                writingItemAt: url, options: .forReplacing,
                error: &coordinationError
            ) { coordinatedURL in
                let success = sceneToSave.write(
                    to: coordinatedURL,
                    options: nil,
                    delegate: nil,
                    progressHandler: nil
                )
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "SceneKitSaveError", code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to write SCNScene"]
                    ))
                }
            }
            
            if let err = coordinationError {
                continuation.resume(throwing: err)
            }
        }
        
        await updateMetadata(for: url)
    }
    
    // MARK: - Convert to USDZ
    func convertToUSDZ(sourceName: String) async throws -> URL {
        guard let scene = self.scene else {
            throw USDZConversionError.noSceneLoaded
        }
        
        isConverting = true
        defer { isConverting = false }
        
        return try await Task.detached(priority: .userInitiated) {
            try USDZConverter.convert(scene: scene, sourceName: sourceName)
        }.value
    }
    
    // MARK: - iCloud Download
    private func downloadIfNeeded(_ url: URL) async throws {
        let isUbiquitous = (try? url.resourceValues(forKeys: [.isUbiquitousItemKey]))?.isUbiquitousItem == true
        guard isUbiquitous else { return }
        
        let resourceValues = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        guard resourceValues.ubiquitousItemDownloadingStatus != .current else { return }
        
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        
        var attempts = 0
        while attempts < 40 {
            try await Task.sleep(nanoseconds: 250_000_000)
            let status = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                .ubiquitousItemDownloadingStatus
            if status == .current { return }
            attempts += 1
        }
        
        throw NSError(domain: "iCloudDownloadError", code: 3,
                      userInfo: [NSLocalizedDescriptionKey: "Timed out downloading from iCloud"])
    }
    
    // MARK: - Metadata
    private func updateMetadata(for url: URL) async {
        do {
            let keys: Set<URLResourceKey> = [.fileSizeKey, .creationDateKey, .contentModificationDateKey]
            let values = try url.resourceValues(forKeys: keys)
            
            fileMetadata = FileMetadata(
                name: url.lastPathComponent,
                size: Int64(values.fileSize ?? 0),
                creationDate: values.creationDate,
                modificationDate: values.contentModificationDate,
                path: url.path
            )
        } catch {
            print("Metadata error: \(error)")
            fileMetadata = nil
        }
    }
    
    struct FileMetadata: Identifiable {
        let id = UUID()
        let name: String
        let size: Int64
        let creationDate: Date?
        let modificationDate: Date?
        let path: String
    }
    
    func clear() {
        scene        = nil
        fileMetadata = nil
        errorMessage = nil
    }
}
