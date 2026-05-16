// FileManagerService.swift
// 

import Foundation

/// A dedicated service class for managing persistent file storage
/// Provides comprehensive file operations with error handling and logging
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
                let error = NSError(domain: "FileManagerService",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"])
                completion(.failure(error))
                return
            }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(at: documentsPath,
                                                                     includingPropertiesForKeys: [.fileSizeKey, .isHiddenKey])
                
                var removedCount = 0
                var failedFiles: [(name: String, error: String)] = []
                var skippedFiles: [String] = []
                
                for fileURL in files {
                    let fileName = fileURL.lastPathComponent
                    
                    // Skip hidden files
                    if fileName.hasPrefix(".") {
                        skippedFiles.append(fileName)
                        continue
                    }
                    
                    // Skip files matching skip patterns
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
                
                DispatchQueue.main.async {
                    completion(.success(result))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Removes all non-hidden files from the Documents directory (async/await version)
    /// - Parameter skipPatterns: File name patterns to skip
    /// - Returns: RemovalResult with operation details
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
    /// - Returns: RemovalResult with operation details
    func removeFilesByExtension(_ extensions: [String],
                                completion: @escaping (Result<RemovalResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let documentsPath = self.documentsDirectory else {
                let error = NSError(domain: "FileManagerService",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"])
                completion(.failure(error))
                return
            }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(at: documentsPath,
                                                                     includingPropertiesForKeys: [.fileSizeKey])
                
                var removedCount = 0
                var failedFiles: [(name: String, error: String)] = []
                
                for fileURL in files {
                    let fileName = fileURL.lastPathComponent
                    
                    // Check if file matches any target extension
                    let matchesExtension = extensions.contains { ext in
                        fileName.lowercased().hasSuffix(".\(ext)")
                    }
                    
                    if matchesExtension {
                        do {
                            try self.fileManager.removeItem(at: fileURL)
                            removedCount += 1
                            print("\(self.logTag) ✓ Removed export: \(fileName)")
                        } catch {
                            failedFiles.append((fileName, error.localizedDescription))
                            print("\(self.logTag) ✗ Failed: \(fileName)")
                        }
                    }
                }
                
                let result = RemovalResult(
                    removedCount: removedCount,
                    skippedCount: files.count - removedCount,
                    failedCount: failedFiles.count,
                    failedFiles: failedFiles.map { $0.name },
                    skippedFiles: []
                )
                
                DispatchQueue.main.async {
                    completion(.success(result))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
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
    /// - Returns: Array of FileInfo objects
    func listAllFiles() -> [FileInfo] {
        guard let documentsPath = documentsDirectory else {
            return []
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsPath,
                                                            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .isHiddenKey])
            
            return files.compactMap { url in
                guard let attrs = try? url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey]),
                      let size = attrs.fileSize,
                      let creationDate = attrs.creationDate else {
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
    /// - Returns: Total size in bytes
    func totalDocumentsSize() -> Int64 {
        let files = listAllFiles()
        return files.reduce(0) { $0 + $1.size }
    }
    
    /// Formats file size for human-readable display
    /// - Parameter bytes: Size in bytes
    /// - Returns: Formatted string (e.g., "1.5 MB")
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Checks if a specific file exists
    /// - Parameter fileName: Name of the file to check
    /// - Returns: Boolean indicating existence
    func fileExists(_ fileName: String) -> Bool {
        guard let documentsPath = documentsDirectory else {
            return false
        }
        
        let fileURL = documentsPath.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Gets the URL for a file in Documents directory
    /// - Parameter fileName: Name of the file
    /// - Returns: Optional URL if file exists
    func fileURL(for fileName: String) -> URL? {
        guard let documentsPath = documentsDirectory else {
            return nil
        }
        
        return documentsPath.appendingPathComponent(fileName)
    }
    
    // MARK: - Cleanup Operations
    
    /// Removes old files based on age threshold
    /// - Parameter daysOld: Remove files older than this many days
    /// - Returns: RemovalResult with operation details
    func removeFilesOlderThan(daysOld: Int,
                              completion: @escaping (Result<RemovalResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                let error = NSError(domain: "FileManagerService",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid instance"])
                completion(.failure(error))
                return
            }
            
            let cutoffDate = Date().addingTimeInterval(-Double(daysOld) * 86400)
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
            
            let result = RemovalResult(
                removedCount: removedCount,
                skippedCount: files.count - removedCount,
                failedCount: failedFiles.count,
                failedFiles: failedFiles.map { $0.name },
                skippedFiles: []
            )
            
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
    }
    
    // MARK: - Diagnostic Methods
    
    /// Generates a diagnostic report of the current storage state
    /// - Returns: Formatted report string
    func generateStorageReport() -> String {
        let files = listAllFiles()
        let totalSize = totalDocumentsSize()
        
        var report = "=== Storage Report ===\n"
        report += "Total Files: \(files.count)\n"
        report += "Total Size: \(formatFileSize(totalSize))\n"
        report += "\n--- Files ---\n"
        
        for file in files.sorted(by: { $0.size > $1.size }) {
            report += "• \(file.name) - \(formatFileSize(file.size))\n"
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
    
    var isSuccess: Bool {
        failedCount == 0
    }
    
    var summary: String {
        var parts: [String] = []
        parts.append("Removed: \(removedCount)")
        if skippedCount > 0 {
            parts.append("Skipped: \(skippedCount)")
        }
        if failedCount > 0 {
            parts.append("Failed: \(failedCount)")
        }
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
    
    var formattedSize: String {
        FileManagerService.shared.formatFileSize(size)
    }
}

