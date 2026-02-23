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
            // Keep UI-state update on MainActor
            previewText = ""
            errorMessage = error.localizedDescription
        }
    }
    
    func readFileForPreview(url: URL) {
        // Start security-scoped access synchronously before handing off work.
        let didStart = url.startAccessingSecurityScopedResource()
        
        // Use structured concurrency: perform blocking I/O off the actor via Task.detached,
        // then resume on MainActor for state updates.
        Task { [weak self] in
            do {
                // Detached task performs the blocking I/O
                let data = try await Task.detached { [url] in
                    try self?.fileService.readData(from: url) ?? Data(contentsOf: url)
                    //  reference to captured var 'self' in concurrently-executing code
                }.value
                
                // Build preview text (pure computation)
                let preview = Self.makePreviewText(from: data, maxChars: self?.maxPreviewChars ?? 20_000)
                
                // Ensure we still have self on MainActor, then update @Published properties
                guard let self = self else {
                    if didStart { url.stopAccessingSecurityScopedResource() }
                    return
                }
                self.previewText = preview
                self.errorMessage = nil
            } catch {
                guard let self = self else {
                    if didStart { url.stopAccessingSecurityScopedResource() }
                    return
                }
                self.previewText = ""
                self.errorMessage = error.localizedDescription
            }
            
            if didStart { url.stopAccessingSecurityScopedResource() }
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
            return "Binary file — \(data.count) bytes"
        }
    }
    
    // Optional helpers you can add:
    func clear() {
        pickedURLs = []
        previewText = ""
        errorMessage = nil
    }
}
