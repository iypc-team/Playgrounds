// FileManagerViewModel.swift
// View model with safe file manager usage and no force-unwraps

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
    
    func saveImage() {
        guard let image = thisImage else {
            infoMessage = "No image to save."
            return
        }
        do {
            let savedURL = try mgr.saveUIImage(image, named: imageName)
            infoMessage = "Saved to: \(savedURL.path)"
        } catch {
            infoMessage = "Save failed: \(error.localizedDescription)"
        }
    }
    
    func deleteImage() {
        do {
            try mgr.deleteImage(named: imageName)
            infoMessage = "Deleted image '\(imageName)'."
            // clear local reference if it refers to the deleted file
            thisImage = nil
            thisImageSize = nil
        } catch {
            infoMessage = "Delete failed: \(error.localizedDescription)"
        }
    }
    
    func deleteImagesFolder() {
        do {
            try mgr.deleteImageFolder()
            infoMessage = "Deleted images folder."
        } catch {
            infoMessage = "Delete folder failed: \(error.localizedDescription)"
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
