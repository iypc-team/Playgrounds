// DocumentManager.swift
// 

import Foundation
import SwiftUI
import SceneKit
import UniformTypeIdentifiers

@MainActor
class DocumentManager: ObservableObject {
    
    @Published var scene: SCNScene?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var fileMetadata: FileMetadata?
    @Published var errorMessage: String?
    
    // MARK: - Load File
    func loadFile(from url: URL) async throws {
        // ✅ Reject anything that isn't a .scn file before doing any work.
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
        
        self.scene = try await loadScene(from: url)
    }
    
    private func loadScene(from url: URL) async throws -> SCNScene {
        try await Task.detached {
            try SCNScene(url: url, options: nil)
        }.value
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
        scene = nil
        fileMetadata = nil
        errorMessage = nil
    }
}
