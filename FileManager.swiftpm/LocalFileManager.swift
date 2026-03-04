// LocalFileManager.swift
// Singleton local file manager. No VM dependencies, safe file I/O, implemented save/get/delete/delete-folder.
//  
//  

import Foundation
import UIKit

enum LocalFileManagerError: Error {
    case couldNotCreateData
    case missingDirectory
    case fileNotFound
    case removeFailed(Error)
}

final class LocalFileManager {
    static let instance = LocalFileManager()
    
    private let fm = FileManager.default
    private(set) var imageDirectoryURL: URL? = nil
    private let imagesDirectoryName = "Images"
    
    private init() {
        do {
            try createImagesDirectoryIfNeeded()
        } catch {
            // directory creation failed; imageDirectoryURL remains nil
            print("LocalFileManager init: failed to create images directory: \(error)")
        }
    }
    
    private func createImagesDirectoryIfNeeded() throws {
        guard let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw LocalFileManagerError.missingDirectory
        }
        let imagesDir = caches.appendingPathComponent(imagesDirectoryName, isDirectory: true)
        if !fm.fileExists(atPath: imagesDir.path) {
            try fm.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
        }
        imageDirectoryURL = imagesDir
    }
    
    // MARK: - Save
    
    /// Save UIImage as PNG data to the images directory. Returns the file URL of saved image.
    /// - Parameters:
    ///   - image: UIImage to save
    ///   - name: file name (provide a file name with extension or without; we'll save as .png if no extension)
    /// - Throws: LocalFileManagerError or underlying write error
    func saveUIImage(_ image: UIImage, named name: String) throws -> URL {
        guard let data = image.pngData() else {
            throw LocalFileManagerError.couldNotCreateData
        }
        guard let imagesDir = imageDirectoryURL else {
            throw LocalFileManagerError.missingDirectory
        }
        
        let filename = name.isEmpty ? UUID().uuidString + ".png" : (name as NSString).lastPathComponent
        let fileNameWithExtension = (filename as NSString).pathExtension.isEmpty ? filename + ".png" : filename
        let fileURL = imagesDir.appendingPathComponent(fileNameWithExtension, isDirectory: false)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            throw error
        }
    }
    
    // MARK: - Deterministic resolution (base-name -> best match)
    
    /// Deterministically resolve a file URL in the Images directory.
    ///
    /// Rules:
    /// 1) If `name` includes an extension (e.g. "Mike.jpg"), resolve exactly that file.
    /// 2) If `name` has no extension (e.g. "Mike"), find all files whose base name matches (case-insensitive),
    ///    then choose deterministically:
    ///    - preferred extension order
    ///    - then lexicographic filename order (stable)
    private func resolveImageFileURL(named name: String) throws -> URL {
        guard let imagesDir = imageDirectoryURL else {
            throw LocalFileManagerError.missingDirectory
        }
        
        let raw = (name as NSString).lastPathComponent
        let providedExt = (raw as NSString).pathExtension
        
        // Rule 1: explicit filename provided
        if !providedExt.isEmpty {
            let exactURL = imagesDir.appendingPathComponent(raw)
            guard fm.fileExists(atPath: exactURL.path) else {
                throw LocalFileManagerError.fileNotFound
            }
            return exactURL
        }
        
        // Rule 2: base-name search (deterministic)
        let preferredExtensions = ["png", "jpg", "jpeg", "heic", "gif", "tiff", "bmp", "webp"]
        
        let urls = try fm.contentsOfDirectory(
            at: imagesDir,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        let matches = urls.filter { url in
            url.deletingPathExtension().lastPathComponent
                .localizedCaseInsensitiveCompare(raw) == .orderedSame
        }
        
        guard !matches.isEmpty else {
            throw LocalFileManagerError.fileNotFound
        }
        
        func rank(for url: URL) -> (Int, String) {
            let ext = url.pathExtension.lowercased()
            let extRank = preferredExtensions.firstIndex(of: ext) ?? Int.max
            let stableName = url.lastPathComponent.lowercased()
            return (extRank, stableName)
        }
        
        return matches.min { rank(for: $0) < rank(for: $1) }!
    }
    
    // MARK: - Delete / Get
    
    /// Delete a specific image file by name.
    /// Accepts either "Mike" (base name) or "Mike.jpg" (explicit filename).
    /// - Throws: LocalFileManagerError or underlying FileManager error
    func deleteImage(named name: String) throws {
        let fileURL = try resolveImageFileURL(named: name)
        
        do {
            try fm.removeItem(at: fileURL)
        } catch {
            throw LocalFileManagerError.removeFailed(error)
        }
    }
    
    /// Delete the entire images folder and its contents.
    func deleteImageFolder() throws {
        guard let imagesDir = imageDirectoryURL else {
            throw LocalFileManagerError.missingDirectory
        }
        
        if fm.fileExists(atPath: imagesDir.path) {
            do {
                try fm.removeItem(at: imagesDir)
                // Recreate directory so instance remains usable
                try createImagesDirectoryIfNeeded()
            } catch {
                throw LocalFileManagerError.removeFailed(error)
            }
        }
    }
    
    /// Get a saved image by name (returns UIImage loaded from file path).
    /// Accepts either "Mike" (base name) or "Mike.jpg" (explicit filename).
    func getImage(named name: String) -> UIImage? {
        guard let url = try? resolveImageFileURL(named: name) else { return nil }
        // UIImage(contentsOfFile:) expects a file system path (not absoluteString)
        return UIImage(contentsOfFile: url.path)
    }
    
    /// Helper: return file URL for a given saved image name (if exists).
    /// Accepts either "Mike" (base name) or "Mike.jpg" (explicit filename).
    func fileURLForImage(named name: String) -> URL? {
        return try? resolveImageFileURL(named: name)
    }
}
