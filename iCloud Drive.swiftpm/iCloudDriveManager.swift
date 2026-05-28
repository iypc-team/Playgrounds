// iCloudDriveManager.swift - Fully Updated & Fixed

import SwiftUI
import Foundation

class iCloudDriveManager: ObservableObject {
    
    @Published var iCloudFiles: [URL] = []
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    private var metadataQuery: NSMetadataQuery?
    private var ubiquityIdentityObserver: NSObjectProtocol?
    
    deinit {
        if let observer = ubiquityIdentityObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        metadataQuery?.stop()
    }
    
    // MARK: - iCloud Documents URL
    var iCloudDocumentsURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
    
    var iCloudAvailable: Bool {
        FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
    }
    
    init() {
        setupiCloudObservers()
    }
    
    // MARK: - iCloud Observers
    private func setupiCloudObservers() {
        ubiquityIdentityObserver = NotificationCenter.default.addObserver(
            forName: .NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.listFiles()
                self?.successMessage = "iCloud account status changed."
            }
        }
        
        setupMetadataQuery()
    }
    
    private func setupMetadataQuery() {
        metadataQuery = NSMetadataQuery()
        metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: metadataQuery,
            queue: .main
        ) { [weak self] _ in
            self?.processMetadataQueryResults()
        }
        
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidUpdate,
            object: metadataQuery,
            queue: .main
        ) { [weak self] _ in
            self?.processMetadataQueryResults()
        }
        
        metadataQuery?.start()
    }
    
    private func processMetadataQueryResults() {
        guard let items = metadataQuery?.results as? [NSMetadataItem] else { return }
        
        let urls = items.compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
        
        DispatchQueue.main.async {
            self.iCloudFiles = urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
        }
    }
    
    // MARK: - Enhanced Error Handling
    private func handleError(_ error: Error, operation: String) {
        DispatchQueue.main.async {
            let nsError = error as NSError
            
            switch nsError.code {
            case NSFileWriteNoPermissionError, NSFileReadNoPermissionError:
                self.errorMessage = "Permission denied during \(operation). Check iCloud settings."
            case NSUbiquitousFileUnavailableError:
                self.errorMessage = "iCloud Drive is not enabled or file unavailable."
            case NSFileWriteOutOfSpaceError:
                self.errorMessage = "Insufficient iCloud storage space."
            default:
                self.errorMessage = "\(operation) failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - List Files
    func listFiles() {
        guard iCloudAvailable else {
            DispatchQueue.main.async { self.errorMessage = "iCloud Drive is not available. Please sign in." }
            return
        }
        
        guard let documentsURL = iCloudDocumentsURL else { return }
        
        let coordinator = NSFileCoordinator(filePresenter: nil)
        
        coordinator.coordinate(readingItemAt: documentsURL, options: [], error: nil) { url in
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch {
                    self.handleError(error, operation: "Create Documents folder")
                    return
                }
            }
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.nameKey, .fileSizeKey, .contentModificationDateKey],
                    options: .skipsHiddenFiles
                )
                
                DispatchQueue.main.async {
                    self.iCloudFiles = contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
                    self.errorMessage = nil
                }
            } catch {
                self.handleError(error, operation: "List files")
            }
        }
    }
    
    // MARK: - Save File
    func saveTextFile(fileName: String, content: String) {
        saveFile(fileName: fileName, data: content.data(using: .utf8) ?? Data())
    }
    
    func saveDataFile(fileName: String, data: Data) {
        saveFile(fileName: fileName, data: data)
    }
    
    private func saveFile(fileName: String, data: Data) {
        guard let documentsURL = iCloudDocumentsURL else { return }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        let coordinator = NSFileCoordinator(filePresenter: nil)
        
        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: nil) { url in
            do {
                try data.write(to: url, options: .atomic)
                DispatchQueue.main.async {
                    self.successMessage = "'\(fileName)' saved to iCloud."
                    self.listFiles()
                }
            } catch {
                self.handleError(error, operation: "Save")
            }
        }
    }
    
    // MARK: - Delete File
    func deleteFile(at url: URL) {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        
        coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil) { urlToDelete in
            do {
                try FileManager.default.removeItem(at: urlToDelete)
                DispatchQueue.main.async {
                    self.successMessage = "'\(url.lastPathComponent)' deleted."
                    self.listFiles()
                }
            } catch {
                self.handleError(error, operation: "Delete")
            }
        }
    }
    
    // MARK: - Conflict Resolution (Fixed)
    func resolveConflicts(for url: URL) {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        
        coordinator.coordinate(writingItemAt: url, options: [], error: nil) { _ in
            do {
                // Get all conflict versions
                let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItem(at: url)
                
                if let latestConflict = conflictVersions?.first {
                    // Example strategy: Keep the most recent conflict version
                    try latestConflict.replaceItem(at: url, options: .byMoving)
                    
                    // Remove other conflicts
                    for version in conflictVersions?.dropFirst() {
                        try version.remove()
                    }
                    
                    DispatchQueue.main.async {
                        self.successMessage = "Conflicts resolved for '\(url.lastPathComponent)'"
                        self.listFiles()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.successMessage = "No conflicts found for '\(url.lastPathComponent)'"
                    }
                }
            } catch {
                self.handleError(error, operation: "Resolve conflict")
            }
        }
    }
    
    // MARK: - Helpers
    func fileSizeString(for url: URL) -> String {
        (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize)
            .map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file) } ?? "—"
    }
    
    func fileModificationDate(for url: URL) -> String {
        guard let date = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate else {
            return "—"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
