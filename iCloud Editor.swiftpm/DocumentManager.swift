// DocumentManager.swift
// 

import Foundation
import SwiftUI

@MainActor
class DocumentManager: ObservableObject {
    @Published var documentData: String = ""
    private let fileCoordinator = NSFileCoordinator()
    
    // Helper to bypass Swift's exclusive access constraints
    private class ErrorBox {
        var error: NSError?
    }
    
    // MARK: - Save File
    func saveFile(data: String, to url: URL) async throws {
        let dataToSave = data.data(using: .utf8) ?? Data()
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        try await Task.detached(priority: .userInitiated) {
            let errorBox = ErrorBox()
            var coordinationError: NSError?
            
            await self.fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { newURL in
                // 
                do {
                    try dataToSave.write(to: newURL, options: .atomic)
                } catch {
                    errorBox.error = error as NSError
                }
            }
            
            if let error = coordinationError { throw error }
            if let writeError = errorBox.error { throw writeError }
        }.value
    }
    
    // MARK: - Load File
    func loadFile(from url: URL) async throws -> String {
        // Ensure the file is downloaded from iCloud
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        
        // Wait for download to complete
        var isDownloaded = false
        while !isDownloaded {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if values.ubiquitousItemDownloadingStatus == .current {
                isDownloaded = true
            } else {
                try await Task.sleep(nanoseconds: 500_000_000) // Poll every 0.5s
            }
        }
        
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
        
        return try await Task.detached(priority: .userInitiated) {
            let errorBox = ErrorBox()
            var result: String = ""
            var coordinationError: NSError?
            
            await self.fileCoordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { readURL in
                do {
                    result = try String(contentsOf: readURL, encoding: .utf8)
                } catch {
                    errorBox.error = error as NSError
                }
            }
            
            if let error = coordinationError { throw error }
            if let readError = errorBox.error { throw readError }
            
            return result
        }.value
    }
}
