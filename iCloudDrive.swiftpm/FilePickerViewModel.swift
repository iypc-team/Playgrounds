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
    @Published var isLoading: Bool = false
    
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
        isLoading = true
        errorMessage = nil
        
        // Capture fileService as a value type — safe to use across concurrency boundaries.
        let capturedFileService: FileService = self.fileService
        let capturedMaxPreviewChars = self.maxPreviewChars
        
        Task { [weak self] in
            // Start security-scoped access inside the Task, immediately before reading.
            let didStart = url.startAccessingSecurityScopedResource()
            defer {
                if didStart {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                let data = try await Task.detached {
                    return try capturedFileService.readData(from: url)
                }.value
                
                let preview = Self.makePreviewText(from: data, maxChars: capturedMaxPreviewChars)
                
                guard let self = self else { return }
                self.previewText = preview
                self.errorMessage = nil
                self.isLoading = false
                
            } catch {
                guard let self = self else { return }
                self.previewText = ""
                self.errorMessage = error.localizedDescription
                self.isLoading = false
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
