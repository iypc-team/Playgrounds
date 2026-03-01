// LocalFileManager.swift
// Singleton local file manager. No VM dependencies, safe file I/O, implemented save/get/delete/delete-folder.

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
    
    /// Delete a specific image file by name (name should match how it was saved).
    /// - Throws: LocalFileManagerError or underlying FileManager error
    func deleteImage(named name: String) throws {
        guard let imagesDir = imageDirectoryURL else {
            throw LocalFileManagerError.missingDirectory
        }
        let filename = (name as NSString).lastPathComponent
        let fileURL = imagesDir.appendingPathComponent(filename)
        guard fm.fileExists(atPath: fileURL.path) else {
            throw LocalFileManagerError.fileNotFound
        }
        do {
            try fm.removeItem(at: fileURL)
        } catch {
            throw LocalFileManagerError.removeFailed(error)
        }
    }
    
    /// Delete the entire images folder and its contents.
    /// - Throws: underlying FileManager error
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
        } else {
            // nothing to do
        }
    }
    
    /// Get a saved image by name (returns UIImage loaded from file path).
    func getImage(named name: String) -> UIImage? {
        guard let imagesDir = imageDirectoryURL else { return nil }
        let filename = (name as NSString).lastPathComponent
        let fileURL = imagesDir.appendingPathComponent(filename)
        guard fm.fileExists(atPath: fileURL.path) else { return nil }
        // UIImage(contentsOfFile:) expects a file system path (not absoluteString)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Helper: return file URL for a given saved image name (if exists)
    func fileURLForImage(named name: String) -> URL? {
        guard let imagesDir = imageDirectoryURL else { return nil }
        let filename = (name as NSString).lastPathComponent
        let fileURL = imagesDir.appendingPathComponent(filename)
        return fm.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}
