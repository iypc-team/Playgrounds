// DocumentManager.swift
import Foundation
import SwiftUI
import SceneKit
import UniformTypeIdentifiers

@MainActor
class DocumentManager: ObservableObject {
    
    @Published var documentData: String = ""
    @Published var scene: SCNScene?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var fileMetadata: FileMetadata?
    @Published var isSceneFile = false
    @Published var errorMessage: String?
    
    // MARK: - Load File
    func loadFile(from url: URL) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        await updateMetadata(for: url)
        try await downloadIfNeeded(url)
        
        let isSCN = url.pathExtension.lowercased() == "scn"
        isSceneFile = isSCN
        
        if isSCN {
            documentData = ""
            self.scene = try await loadScene(from: url)
        } else {
            let data = try Data(contentsOf: url)
            documentData = String(decoding: data, as: UTF8.self)
            self.scene = nil
        }
    }
    
    private func loadScene(from url: URL) async throws -> SCNScene {
        try await Task.detached {
            try SCNScene(url: url, options: nil)
        }.value
    }
    
    // MARK: - Save File
    func saveFile(to url: URL) async throws {
        isSaving = true
        defer { isSaving = false }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        let isSCN = url.pathExtension.lowercased() == "scn"
        let sceneToSave = self.scene
        let textToSave = self.documentData
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var coordinationError: NSError?
            
            coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { coordinatedURL in
                do {
                    if isSCN, let scene = sceneToSave {
                        let success = scene.write(to: coordinatedURL,
                                                  options: nil,
                                                  delegate: nil,
                                                  progressHandler: nil)
                        if !success {
                            throw NSError(domain: "SceneKitSaveError", code: 1,
                                          userInfo: [NSLocalizedDescriptionKey: "Failed to write SCNScene"])
                        }
                    } else {
                        guard let data = textToSave.data(using: .utf8) else {
                            throw NSError(domain: "TextEncodingError", code: 2,
                                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode text"])
                        }
                        try data.write(to: coordinatedURL, options: .atomic)
                    }
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
            
            if let err = coordinationError {
                continuation.resume(throwing: err)
            }
        }
        
        await updateMetadata(for: url)
    }
    
    // MARK: - iCloud Download
    private func downloadIfNeeded(_ url: URL) async throws {
        // ✅ Skip entirely for non-iCloud (local) files
        let isUbiquitous = (try? url.resourceValues(forKeys: [.isUbiquitousItemKey]))?.isUbiquitousItem == true
        guard isUbiquitous else { return }
        
        // ✅ resourceValues(forKeys:) is synchronous — no `await`
        let resourceValues = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        guard resourceValues.ubiquitousItemDownloadingStatus != .current else { return }
        
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        
        var attempts = 0
        while attempts < 40 {
            try await Task.sleep(nanoseconds: 250_000_000) // ✅ genuinely async
            // ✅ resourceValues(forKeys:) is synchronous — no `await`
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
        documentData = ""
        scene = nil
        fileMetadata = nil
        isSceneFile = false
        errorMessage = nil
    }
}
