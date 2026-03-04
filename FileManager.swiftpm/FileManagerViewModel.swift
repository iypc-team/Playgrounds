
// FileManagerViewModel.swift
// View model with safe file manager usage and no force-unwraps
// Updated: perform file I/O on a background queue to avoid blocking the main thread
//  print(infoMessage) print("\n\(infoMessage)")
//  print(self.infoMessage) print("\n\(self.infoMessage )") Saving... Deleting...
//  
// images in bundle.

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
    @Published var imageName: String = "Planet"
    @Published var availableImages: [String] = []  // Added: List of available images from Assets folder
    
    init() {
        getImageFromAssetsFolder()
        
        // Enumerate example - only if image directory exists
        if let path = mgr.imageDirectoryURL {
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
            Task {
                do {
                    let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: nil, options: options, errorHandler: nil)
                    while let item = enumerator?.nextObject() as? URL {
                        if item.pathExtension == "swift" {
                            print(item.lastPathComponent)
                        }
                    }
                }
            }
        } else {
            infoMessage = "Images directory not available."
            print("\n\(self.infoMessage )")
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
            print("\n\(self.infoMessage )")
            return
        }
        thisImage = ui
        thisImageSize = ui.size
        infoMessage = "Loaded asset '\(imageName)'."
    }
    
    func pickImage() {
        // List all images in the main bundle (not in a subdirectory)
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "heic", "tiff", "bmp", "webp"]
        var allImageURLs: [URL] = []
        
        for ext in imageExtensions {
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                allImageURLs.append(contentsOf: urls)
            }
        }
        
        // Extract unique image names (without extensions)
        let imageNames = allImageURLs.map { $0.deletingPathExtension().lastPathComponent }
        availableImages = Array(Set(imageNames))  // Remove duplicates
        
        infoMessage = "Found \(availableImages.count) images in bundle."
        print("\n\(self.infoMessage )")
    }
    
    /// Save image off the main thread to avoid UI blocking.
    /// The method remains synchronous from the caller's perspective (returns immediately),
    /// but the actual file I/O happens in a detached task and UI is updated on the main actor.
    func saveImage() {
        guard let image = thisImage else {
            infoMessage = "No image to save."
            print("\n\(self.infoMessage )")
            return
        }
        
        // Give immediate feedback
        infoMessage = "Saving..."
        print("\n\(self.infoMessage )")
        
        // Perform write on background
        let name = imageName // capture atomically
        let imageToSave = image // capture image data to avoid race with UI changes
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let savedURL = try self.mgr.saveUIImage(imageToSave, named: name)
                await MainActor.run {
                    self.infoMessage = "Saved to: \(savedURL.path)"
                    print("\(self.infoMessage )")
                }
            } catch {
                await MainActor.run {
                    self.infoMessage = "Save failed: \(error.localizedDescription)"
                    print("\(self.infoMessage )")
                }
            }
        }
    }
    
    /// Delete image off the main thread and update UI on main actor.
    func deleteImage() {
        let name = imageName // capture name
        // Provide immediate feedback
        infoMessage = "Deleting..."
        print("\n\(self.infoMessage )")
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                try self.mgr.deleteImage(named: name)
                await MainActor.run {
                    self.infoMessage = "Deleted image '\(name)'."
                    print("\(self.infoMessage )")
                    // clear local reference if it refers to the deleted file
                    self.thisImage = nil
                    self.thisImageSize = nil
                }
            } catch {
                await MainActor.run {
                    self.infoMessage = "Delete failed: \(error.localizedDescription)"
                    print("\(self.infoMessage )")
                }
            }
        }
    }
    
    func deleteImagesFolder() {
        do {
            try mgr.deleteImageFolder()
            infoMessage = "Deleted images folder and recreated it."
            print("\n\(self.infoMessage )")
            // Optionally clear UI
            thisImage = nil
            thisImageSize = nil
        } catch {
            infoMessage = "Failed to delete images folder: \(error.localizedDescription)"
            print("\n\(self.infoMessage )")
        }
    }
}
