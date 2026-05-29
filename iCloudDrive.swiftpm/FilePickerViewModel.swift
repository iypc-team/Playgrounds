//  FilePickerViewModel.swift
//  

import Foundation
import SwiftUI

// Optional abstraction for file operations to make testing easier.
protocol FileService {
    func readData(from url: URL) throws -> Data
}

struct DefaultFileService: FileService {
    func readData(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
}

@MainActor
final class FilePickerViewModel: ObservableObject {
    @Published var pickedURLs: [URL] = []
    @Published var previewText: String = ""
    @Published var errorMessage: String?
    
    private let fileService: FileService
    private let maxPreviewChars = 20_000
    
    init(fileService: FileService = DefaultFileService()) {
        self.fileService = fileService
    }
    
    func handle(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            pickedURLs = urls
            if let first = urls.first {
                readFileForPreview(url: first)
            } else {
                previewText = ""
                errorMessage = nil
            }
        case .failure(let error):
            previewText = ""
            errorMessage = error.localizedDescription
        }
    }
    
    func readFileForPreview(url: URL) {
        // Start security-scoped access synchronously before handing off work.
        let didStart = url.startAccessingSecurityScopedResource()
        
        Task { [weak self] in
            // Ensure cleanup always happens, even on early returns or errors
            defer {
                if didStart {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Capture the pieces we need from self on the MainActor
            let capturedFileService = self?.fileService
            let capturedMaxPreviewChars = self?.maxPreviewChars ?? 20_000
            
            do {
                let data = try await Task.detached {
                    guard let service = capturedFileService else {
                        // Fallback
                        return try Data(contentsOf: url)
                    }
                    return try service.readData(from: url)
                }.value
                
                // Build preview text
                let preview = Self.makePreviewText(from: data, maxChars: capturedMaxPreviewChars)
                
                // Update UI on MainActor
                guard let self = self else { return }
                self.previewText = preview
                self.errorMessage = nil
                
            } catch {
                guard let self = self else { return }
                self.previewText = ""
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // Small helper to centralize preview logic; pure function.
    private static func makePreviewText(from data: Data, maxChars: Int) -> String {
        if let text = String(data: data, encoding: .utf8) {
            if text.count > maxChars {
                let prefix = text.prefix(maxChars)
                return String(prefix) + "\n\n--- Preview truncated ---"
            } else {
                return text
            }
        } else {
            return "Binary file or unreadable encoding (\(data.count) bytes)"
        }
    }
}
