// DocumentManager.swift
// 

import Foundation
import SwiftUI

@MainActor
class DocumentManager: ObservableObject {
    @Published var documentData: String = ""
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var fileMetadata: FileMetadata?
    @Published var lastError: DocumentError?
    
    // ✅ Removed instance-level fileCoordinator — no longer needed
    
    // MARK: - Custom Errors
    enum DocumentError: LocalizedError {
        case accessDenied
        case iCloudDownloadTimeout
        case fileTooLarge(sizeMB: Double)
        case writeFailed(reason: String)
        case readFailed(reason: String)
        case metadataError
        case coordinationFailed
        
        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Unable to access the file. Security scope may have expired."
            case .iCloudDownloadTimeout:
                return "iCloud file download timed out. Please try again."
            case .fileTooLarge(let size):
                return "File is very large (\(String(format: "%.1f", size)) MB) and may cause performance issues."
            case .writeFailed(let reason):
                return "Failed to save file: \(reason)"
            case .readFailed(let reason):
                return "Failed to read file: \(reason)"
            case .metadataError:
                return "Could not read file metadata."
            case .coordinationFailed:
                return "File coordination failed. Another process may be using the file."
            }
        }
    }
    
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
        lastError = nil
        defer { isSaving = false }
        
        let dataToSave = data.data(using: .utf8) ?? Data()
        
        try await withSecurityScopedAccess(url) { scopedURL in
            try await coordinateWrite(to: scopedURL, data: dataToSave)
        }
        
        await updateMetadata(for: url)
    }
    
    // MARK: - Load
    func loadFile(from url: URL) async throws -> String {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        
        return try await withSecurityScopedAccess(url) { scopedURL in
            await updateMetadata(for: scopedURL)
            try await downloadIfNeeded(scopedURL)
            
            if let size = fileMetadata?.fileSize, size > 10_000_000 {
                let sizeMB = Double(size) / 1_000_000
                if sizeMB > 50 {
                    throw DocumentError.fileTooLarge(sizeMB: sizeMB)
                }
            }
            
            return try await readFileContents(from: scopedURL)
        }
    }
    
    // MARK: - Private Helpers
    
    private func withSecurityScopedAccess<T>(
        _ url: URL,
        operation: (URL) async throws -> T
    ) async throws -> T {
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        guard shouldStop else {
            throw DocumentError.accessDenied
        }
        
        return try await operation(url)
    }
    
    private func coordinateWrite(to url: URL, data: Data) async throws {
        try await Task.detached {
            // ✅ Create coordinator locally — no capture of non-Sendable type
            let coordinator = NSFileCoordinator()
            var coordinationError: NSError?
            var writeError: Error?
            
            coordinator.coordinate(
                writingItemAt: url,
                options: .forReplacing,
                error: &coordinationError
            ) { newURL in
                do {
                    try data.write(to: newURL, options: .atomic)
                } catch {
                    writeError = error
                }
            }
            
            if let error = coordinationError ?? (writeError as NSError?) {
                throw DocumentError.writeFailed(reason: error.localizedDescription)
            }
        }.value
    }
    
    private func readFileContents(from url: URL) async throws -> String {
        try await Task.detached {
            let data = try Data(contentsOf: url)
            // ✅ String(data:encoding:) returns String? — valid for guard let
            guard let text = String(data: data, encoding: .utf8) else {
                throw DocumentError.readFailed(reason: "Invalid UTF-8 encoding")
            }
            return text
        }.value
    }
    
    // MARK: - Metadata
    private func updateMetadata(for url: URL) async {
        do {
            let keys: Set<URLResourceKey> = [
                .fileSizeKey,
                .contentModificationDateKey,
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                .nameKey
            ]
            
            let resourceValues = try url.resourceValues(forKeys: keys)
            let status = resourceValues.ubiquitousItemDownloadingStatus?.rawValue ?? "unknown"
            
            fileMetadata = FileMetadata(
                name: resourceValues.name ?? url.lastPathComponent,
                lastModified: resourceValues.contentModificationDate,
                fileSize: Int64(resourceValues.fileSize ?? 0),
                isDownloaded: resourceValues.ubiquitousItemDownloadingStatus == .current,
                iCloudStatus: status
            )
        } catch {
            print("Metadata update failed: \(error)")
            lastError = .metadataError
        }
    }
    
    // MARK: - iCloud Download
    private func downloadIfNeeded(_ url: URL) async throws {
        let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        
        guard values.ubiquitousItemDownloadingStatus != .current else { return }
        
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        
        // Poll with timeout (15 seconds)
        for _ in 0..<30 {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            
            let status = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                .ubiquitousItemDownloadingStatus
            
            if status == .current {
                await updateMetadata(for: url)
                return
            }
        }
        
        throw DocumentError.iCloudDownloadTimeout
    }
}
