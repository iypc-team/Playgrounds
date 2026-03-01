// FileManagerViewModel.swift
// View model with safe file manager usage and no force-unwraps
// Updated: perform file I/O on a background queue to avoid blocking the main thread

import SwiftUI
import Foundation
import Combine
import UIKit

class FileManagerViewModel: ObservableObject {
    let fileManager = Foundation.FileManager.default
    let mgr = LocalFileManager.instance
    
    @Published var thisImage: UIImage? = nil
    @Published var thisImageSize: CGSize? = nil
    @Published var infoMessage: String = "ok"
    @Published var imageName: String = "Italy_4"
    
    init() {
        getImageFromAssetsFolder()
        
        // Enumerate example - only if image directory exists
        if let path = mgr.imageDirectoryURL {
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
            Task {
                for await item in walkDirectory(at: path, options: options) {
                    if item.pathExtension == "swift" {
                        print(item.lastPathComponent)
                    }
                }
            }
        } else {
            infoMessage = "Images directory not available."
        }
        
        if let caches = fileManager.allRecordedCachesData() {
            print("Caches:", caches)
        }
        if let docs = fileManager.allDocumentsDirectoryData() {
            print("Documents:", docs)
        }
        if let temps = fileManager.allTemporaryDirectoryData() {
            print("Temporary:", temps)
        }
    }
    
    func getImageFromAssetsFolder() {
        guard let ui = UIImage(named: imageName) else {
            thisImage = nil
            thisImageSize = nil
            infoMessage = "Asset image '\(imageName)' not found."
            return
        }
        thisImage = ui
        thisImageSize = ui.size
        infoMessage = "Loaded asset '\(imageName)'."
    }
    
    /// Save image off the main thread to avoid UI blocking.
    /// The method remains synchronous from the caller's perspective (returns immediately),
    /// but the actual file I/O happens in a detached task and UI is updated on the main actor.
    func saveImage() {
        guard let image = thisImage else {
            infoMessage = "No image to save."
            return
        }
        
        // Give immediate feedback
        infoMessage = "Saving..."
        
        // Perform write on background
        let name = imageName // capture atomically
        let imageToSave = image // capture image data to avoid race with UI changes
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let savedURL = try self.mgr.saveUIImage(imageToSave, named: name)
                await MainActor.run {
                    self.infoMessage = "Saved to: \(savedURL.path)"
                }
            } catch {
                await MainActor.run {
                    self.infoMessage = "Save failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Delete image off the main thread and update UI on main actor.
    func deleteImage() {
        let name = imageName // capture name
        // Provide immediate feedback
        infoMessage = "Deleting..."
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                try self.mgr.deleteImage(named: name)
                await MainActor.run {
                    self.infoMessage = "Deleted image '\(name)'."
                    // clear local reference if it refers to the deleted file
                    self.thisImage = nil
                    self.thisImageSize = nil
                }
            } catch {
                await MainActor.run {
                    self.infoMessage = "Delete failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Delete images folder off the main thread and update UI on main actor.
    func deleteImagesFolder() {
        infoMessage = "Deleting images folder..."
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                try self.mgr.deleteImageFolder()
                await MainActor.run {
                    self.infoMessage = "Deleted images folder."
                }
            } catch {
                await MainActor.run {
                    self.infoMessage = "Delete folder failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Recursive iteration
    func walkDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions) -> AsyncStream<URL> {
        AsyncStream { continuation in
            Task {
                let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
                while let fileURL = enumerator?.nextObject() as? URL {
                    if fileURL.hasDirectoryPath {
                        for await item in walkDirectory(at: fileURL, options: options) {
                            continuation.yield(item)
                        }
                    } else {
                        continuation.yield(fileURL)
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func listFilesFromDocumentsFolder() {
        do {
            let documentDirectory = try Foundation.FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let directoryContents = try Foundation.FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            print("directoryContents:", directoryContents.map { $0.localizedName ?? $0.lastPathComponent })
            
            // Hide file extension for display
            for var url in directoryContents {
                url.hasHiddenExtension = true
            }
            for url in directoryContents {
                print(url.localizedName ?? url.lastPathComponent)
            }
            
            let mp3s = directoryContents.filter(\.isMP3).map { $0.localizedName ?? $0.lastPathComponent }
            print("mp3s:", mp3s)
        } catch {
            print(error)
        }
    }
    
    func listContentsRootDirectory() {
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: "/")
            print("fileList: \(fileList.count) ")
            print(fileList.debugDescription)
            for filename in fileList {
                print(filename)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        print("Root Directory search completed...\n")
    }
}
