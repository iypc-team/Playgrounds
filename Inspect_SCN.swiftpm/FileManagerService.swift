// FileManagerService.swift
//

import Foundation

// MARK: - Error Types

enum FileManagerServiceError: LocalizedError {
    case documentsUnavailable
    case invalidFileName(String)
    case directoryCreationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .documentsUnavailable:
            return "Unable to access Documents directory."
        case .invalidFileName(let name):
            return "Invalid file name: '\(name)'."
        case .directoryCreationFailed(let error):
            return "Failed to create directory: \(error.localizedDescription)"
        }
    }
}

/// A dedicated service class for managing persistent file storage.
/// Provides comprehensive file operations with error handling and logging.
class FileManagerService {
    
    // MARK: - Singleton Instance
    
    static let shared = FileManagerService()
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let logTag = "[FileManagerService]"
    
    /// The app's Documents directory URL
    var documentsDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Export Path Resolution
    
    /// Builds and returns a destination URL for an exported scene file.
    /// Creates the Exports subfolder in Documents if it doesn't already exist.
    /// - Parameters:
    ///   - baseName: Source file name including any extension (e.g. "smooth_ship.scn")
    ///   - format: Export format extension (e.g. "usdz" or "scn")
    /// - Returns: A fully resolved destination URL inside Documents/Exports/
    /// - Throws: `FileManagerServiceError` if the directory is unavailable or cannot be created
    func exportDestinationURL(for baseName: String, format: String) throws -> URL {
        guard let documentsURL = documentsDirectory else {
            throw FileManagerServiceError.documentsUnavailable
        }
        
        // Robustly strip any source extension (.scn, .usdz, etc.)
        let cleanName = URL(fileURLWithPath: baseName)
            .deletingPathExtension()
            .lastPathComponent
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanName.isEmpty else {
            throw FileManagerServiceError.invalidFileName(baseName)
        }
        
        let finalName = "\(cleanName)_export.\(format)"
        let exportsURL = documentsURL.appendingPathComponent("Exports", isDirectory: true)
        
        if !fileManager.fileExists(atPath: exportsURL.path) {
            do {
                try fileManager.createDirectory(at: exportsURL, withIntermediateDirectories: true)
                print("\(logTag) Created Exports folder at: \(exportsURL.path)")
            } catch {
                throw FileManagerServiceError.directoryCreationFailed(error)
            }
        }
        
        let destinationURL = exportsURL.appendingPathComponent(finalName)
        print("\(logTag) Export destination resolved: \(destinationURL.path)")
        return destinationURL
    }
    
    // MARK: - Core Operations
    
    /// Removes all non-hidden files from the Documents directory
    /// - Parameters:
    ///   - skipPatterns: File name patterns to skip (e.g., ["system.config"])
    ///   - completion: Callback with result containing count and errors
    func removeAllFiles(skipPatterns: [String] = [],
                        completion: @escaping (Result<RemovalResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let documentsPath = self.documentsDirectory else {
                completion(.failure(FileManagerServiceError.documentsUnavailable))
                return
            }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(
                    at: documentsPath,
                    includingPropertiesForKeys: [.fileSizeKey, .isHiddenKey]
                )
                
                var removedCount = 0
                var failedFiles: [(name: String, error: String)] = []
                var skippedFiles: [String] = []
                
                for fileURL in files {
                    let fileName = fileURL.lastPathComponent
                    
                    if fileName.hasPrefix(".") {
                        skippedFiles.append(fileName)
                        continue
                    }
                    
                    if skipPatterns.contains(where: { fileName.contains($0) }) {
                        skippedFiles.append(fileName)
                        continue
                    }
                    
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                        removedCount += 1
                        print("\(self.logTag) ✓ Removed: \(fileName)")
                    } catch {
                        failedFiles.append((fileName, error.localizedDescription))
                        print("\(self.logTag) ✗ Failed: \(fileName) - \(error.localizedDescription)")
                    }
                }
                
                let result = RemovalResult(
                    removedCount: removedCount,
                    skippedCount: skippedFiles.count,
                    failedCount: failedFiles.count,
                    failedFiles: failedFiles.map { $0.name },
                    skippedFiles: skippedFiles
                )
                
                DispatchQueue.main.async { completion(.success(result)) }
                
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    /// Removes all non-hidden files from the Documents directory (async/await version)
    @discardableResult
    func removeAllFilesAsync(skipPatterns: [String] = []) async -> Result<RemovalResult, Error> {
        await withCheckedContinuation { continuation in
            removeAllFiles(skipPatterns: skipPatterns) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Removes files matching specific extensions
    /// - Parameter extensions: Array of file extensions to remove (e.g., ["usdz", "scn"])
    func removeFilesByExtension(_ extensions: [String],
                                completion: @escaping (Result<RemovalResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let documentsPath = self.documentsDirectory else {
                completion(.failure(FileManagerServiceError.documentsUnavailable))
                return
            }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(
                    at: documentsPath,
                    includingPropertiesForKeys: [.fileSizeKey]
                )
                
                var removedCount = 0
                var failedFiles: [(name: String, error: String)] = []
                
                for fileURL in files {
                    let fileName = fileURL.lastPathComponent
                    
                    let matchesExtension = extensions.contains { ext in
                        fileName.lowercased().hasSuffix(".\(ext)")
                    }
                    
                    if matchesExtension {
                        do {
                            try self.fileManager.removeItem(at: fileURL)
                            removedCount += 1
                            print("\(self.logTag) ✓ Removed: \(fileName)")
                        } catch {
                            failedFiles.append((fileName, error.localizedDescription))
                            print("\(self.logTag) ✗ Failed: \(fileName)")
                        }
                    }
                }
                
                // Fixed: exclude failed files from skippedCount
                let result = RemovalResult(
                    removedCount: removedCount,
                    skippedCount: files.count - removedCount - failedFiles.count,
                    failedCount: failedFiles.count,
                    failedFiles: failedFiles.map { $0.name },
                    skippedFiles: []
                )
                
                DispatchQueue.main.async { completion(.success(result)) }
                
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    /// Removes files matching specific extensions (async/await version)
    func removeFilesByExtensionAsync(_ extensions: [String]) async -> Result<RemovalResult, Error> {
        await withCheckedContinuation { continuation in
            removeFilesByExtension(extensions) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - File Listing & Information
    
    /// Lists all files in Documents directory with metadata
    func listAllFiles() -> [FileInfo] {
        guard let documentsPath = documentsDirectory else { return [] }
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: documentsPath,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .isHiddenKey]
            )
            
            return files.compactMap { url -> FileInfo? in
                guard let attrs = try? url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey]),
                      let size = attrs.fileSize,
                      let creationDate = attrs.creationDate else {
                    print("\(logTag) ⚠️ Missing metadata for: \(url.lastPathComponent)")
                    return nil
                }
                
                return FileInfo(
                    name: url.lastPathComponent,
                    url: url,
                    size: Int64(size),
                    creationDate: creationDate,
                    isHidden: url.lastPathComponent.hasPrefix(".")
                )
            }
        } catch {
            print("\(logTag) Failed to list files: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Calculates total size of all files in Documents directory
    func totalDocumentsSize() -> Int64 {
        listAllFiles().reduce(0) { $0 + $1.size }
    }
    
    /// Formats file size for human-readable display (static — no singleton dependency needed)
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Checks if a specific file exists in Documents
    func fileExists(_ fileName: String) -> Bool {
        guard let documentsPath = documentsDirectory else { return false }
        let fileURL = documentsPath.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Returns the URL for a file in Documents only if it actually exists
    func fileURL(for fileName: String) -> URL? {
        guard let documentsPath = documentsDirectory else { return nil }
        let url = documentsPath.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
    
    // MARK: - Cleanup Operations
    
    /// Removes files older than the specified number of days (based on modification date)
    func removeFilesOlderThan(daysOld: Int,
                              completion: @escaping (Result<RemovalResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(.failure(FileManagerServiceError.documentsUnavailable))
                return
            }
            
            // Use Calendar for DST-safe date math
            let cutoffDate = Calendar.current.date(
                byAdding: .day, value: -daysOld, to: Date()
            ) ?? Date()
            
            let files = self.listAllFiles()
            var removedCount = 0
            var failedFiles: [(name: String, error: String)] = []
            
            for fileInfo in files {
                if fileInfo.creationDate < cutoffDate {
                    do {
                        try self.fileManager.removeItem(at: fileInfo.url)
                        removedCount += 1
                        print("\(self.logTag) ✓ Removed old file: \(fileInfo.name)")
                    } catch {
                        failedFiles.append((fileInfo.name, error.localizedDescription))
                    }
                }
            }
            
            // Fixed: exclude failed files from skippedCount
            let result = RemovalResult(
                removedCount: removedCount,
                skippedCount: files.count - removedCount - failedFiles.count,
                failedCount: failedFiles.count,
                failedFiles: failedFiles.map { $0.name },
                skippedFiles: []
            )
            
            DispatchQueue.main.async { completion(.success(result)) }
        }
    }
    
    // MARK: - Diagnostic Methods
    
    /// Generates a diagnostic report of the current storage state
    func generateStorageReport() -> String {
        let files = listAllFiles()
        let totalSize = totalDocumentsSize()
        
        var report = "=== Storage Report ===\n"
        report += "Total Files: \(files.count)\n"
        report += "Total Size: \(FileManagerService.formatFileSize(totalSize))\n"
        report += "\n--- Files ---\n"
        
        for file in files.sorted(by: { $0.size > $1.size }) {
            report += "• \(file.name) - \(FileManagerService.formatFileSize(file.size))\n"
        }
        
        report += "\n=================\n"
        return report
    }
    
    /// Prints storage report to console
    func printStorageReport() {
        print(generateStorageReport())
    }
}

// MARK: - Supporting Types

/// Result of a file removal operation
struct RemovalResult {
    let removedCount: Int
    let skippedCount: Int
    let failedCount: Int
    let failedFiles: [String]
    let skippedFiles: [String]
    
    var isSuccess: Bool { failedCount == 0 }
    
    var summary: String {
        var parts: [String] = []
        parts.append("Removed: \(removedCount)")
        if skippedCount > 0 { parts.append("Skipped: \(skippedCount)") }
        if failedCount > 0  { parts.append("Failed: \(failedCount)") }
        return parts.joined(separator: ", ")
    }
}

/// Metadata for a single file
struct FileInfo {
    let name: String
    let url: URL
    let size: Int64
    let creationDate: Date
    let isHidden: Bool
    
    // Fixed: uses static method — no singleton dependency
    var formattedSize: String {
        FileManagerService.formatFileSize(size)
    }
}
