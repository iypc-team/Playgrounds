// DocumentManager.swift
// 
// DocumentManager.swift
import Foundation
import SwiftUI

@MainActor
class DocumentManager: ObservableObject {
    @Published var documentData: String = ""
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var fileMetadata: FileMetadata?
    
    private let fileCoordinator = NSFileCoordinator()
    
    struct FileMetadata {
        let name: String
        let lastModified: Date?
        let fileSize: Int64
        let isDownloaded: Bool
        let iCloudStatus: String
    }
    
    // MARK: - Save
    func saveFile(data: String, to url: URL) async throws {
        isSaving = true
        defer { isSaving = false }
        
        let dataToSave = data.data(using: .utf8) ?? Data()
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        try await Task.detached { [fileCoordinator] in
            let errorBox = ErrorBox()
            var coordinationError: NSError?
            
            fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { newURL in
                do {
                    try dataToSave.write(to: newURL, options: .atomic)
                } catch {
                    errorBox.error = error as NSError
                }
            }
            
            if let err = coordinationError ?? errorBox.error { throw err }
        }.value
    }
    
    // MARK: - Load with Large File Check
    func loadFile(from url: URL) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        // Update metadata
        await updateMetadata(for: url)
        
        try await downloadIfNeeded(url)
        
        // Large file warning
        if let size = fileMetadata?.fileSize, size > 10_000_000 { // >10MB
            print("⚠️ Large file detected (\(size / 1_000_000) MB). Performance may be affected.")
        }
        
        return try await Task.detached {
            let data = try Data(contentsOf: url)
            return String(decoding: data, as: UTF8.self)
        }.value
    }
    
    private func updateMetadata(for url: URL) async {
        do {
            let resourceValues = try url.resourceValues(forKeys: [
                .fileSizeKey,
                .contentModificationDateKey,
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey
            ])
            
            let status = resourceValues.ubiquitousItemDownloadingStatus?.rawValue ?? "unknown"
            
            fileMetadata = FileMetadata(
                name: url.lastPathComponent,
                lastModified: resourceValues.contentModificationDate,
                fileSize: Int64(resourceValues.fileSize ?? 0),
                isDownloaded: resourceValues.ubiquitousItemDownloadingStatus == .current,
                iCloudStatus: status
            )
        } catch {
            print("Metadata error: \(error)")
        }
    }
    
    private func downloadIfNeeded(_ url: URL) async throws {
        let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        
        guard values.ubiquitousItemDownloadingStatus != .current else { return }
        
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        
        // Timeout after 15s
        for _ in 0..<30 {
            try await Task.sleep(nanoseconds: 500_000_000)
            let status = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                .ubiquitousItemDownloadingStatus
            if status == .current { return }
        }
        throw NSError(domain: "iCloud", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud download timeout"])
    }
    
    private class ErrorBox {
        var error: NSError?
    }
}
