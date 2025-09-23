//  guard
//  Element: Comparable
import SwiftUI
import Foundation
import Combine
import PlaygroundSupport

class FileManagerViewModel:  ObservableObject {
    let fileManager = Foundation.FileManager.default
    let mgr = LocalFileManager.instance
    @Published var thisImage: UIImage? = nil
    @Published var thisImageSize: CGSize? = nil
    @Published var infoMessage: String = "ok"
    
    //    @Published var imageName: String = "1024fighter"
    //    @Published var imageName: String = "IMG_0072"
    //    @Published var imageName: String = "leopard"
    @Published var imageName: String = "Italy_4"
    
    init() {
        print("\nFileManagerViewModel...")
        getImageFromAssetsFolder()
        
        //        let path = URL( string: "<your path>" )
        let path = URL( string: mgr.imageDirectoryString )
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        
        Task {
            let swiftFiles = walkDirectory(at: path!, options: options).filter {
                $0.pathExtension == "swift"
            }
            
            for await item in swiftFiles {
                print(item.lastPathComponent)
            }
        }
        
        print(fileManager.allRecordedCachesData()!)
        print(fileManager.allDocumentsDirectoryData()!)
        print(fileManager.allTemporaryDirectoryData()!)
    }
    
    func getImageFromAssetsFolder() {
        thisImage = UIImage(named: imageName)
        thisImageSize = thisImage!.size
        
        print("getImageFromAssetsFolder() named: \(imageName)")
    }
    
    func saveImage() {
        print("saveImage() called ...\n")
        mgr.saveUIImage(image: thisImage!, named: imageName)
    }
    
    func deleteImage() {
        print("deleteImage() called...")
        mgr.deleteImageFromFileManager(name: imageName)
    }
    
    func deleteImagesFolder() {
        print("deleteImagesFolder() called...")
        mgr.deleteImageFolderFromFileManager()
    }
    
    // Recursive iteration     
    func walkDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions ) -> AsyncStream<URL> {
        AsyncStream { continuation in
            Task {
                let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
                
                while let fileURL = enumerator?.nextObject() as? URL {
                    if fileURL.hasDirectoryPath {
                        for await item in walkDirectory(at: fileURL, options: options) {
                            continuation.yield(item)
                        }
                    } else {
                        continuation.yield( fileURL )
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func listFilesFromDocumentsFolder() {
        do {
            // Get the document directory url
            let documentDirectory = try Foundation.FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            print("documentDirectory: \(documentDirectory.path)\n")
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try Foundation.FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
            print("directoryContents:", directoryContents.map { $0.localizedName ?? $0.lastPathComponent })
            for url in directoryContents {
                print(url.localizedName ?? url.lastPathComponent)
            }
            
            // if you would like to hide the file extension
            for var url in directoryContents {
                url.hasHiddenExtension = true
            }
            for url in directoryContents {
                print(url.localizedName ?? url.lastPathComponent)
            }
            
            // if you want to get all mp3 files located at the documents directory:
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
