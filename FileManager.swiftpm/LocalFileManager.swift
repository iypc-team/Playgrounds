//  deleteImageFromFileManager
//
import SwiftUI
import Foundation
import Combine
import PlaygroundSupport

class LocalFileManager {
    static let instance = LocalFileManager()
    static let vm = FileManagerViewModel()
    
    var urlDirectorySet: Set<URL> = []
    var filePathSet: Set<URL> = []
    
    var imageDirectoryURL: URL? = nil
    var imageDirectoryString: String = ""
    var fileSavePath: URL? = nil
    
    
    init() {
        print("LocalFileManager...\n")
        
        createimageDirectoryURL(named: "Images")
        
        
        
//        print("urlDirectorySet \(urlDirectorySet)\n")
//        print("filePathSet \(filePathSet)\n")
//        print("imageDirectoryURL \(String(describing:  imageDirectoryURL))\n")
//        print("imageDirectoryString \(imageDirectoryString)\n")
//        print("fileSavePath \(String(describing: fileSavePath))\n ")
        
        print("LocalFileManager END")
    }
    
    func createimageDirectoryURL(named: String) {
        print("createimageDirectory(named: String) ")
        guard 
            let imageDirectory = Foundation.FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent( named, isDirectory: true)
                
        else { 
            print("Error creating createimageDirectoryURL\n")
            return
        }
        urlDirectorySet.insert(imageDirectory)
        imageDirectoryURL = imageDirectory
        imageDirectoryString = imageDirectory.absoluteString
        print("imageDirectory: \(imageDirectory)\n")
    }
    
    func saveUIImage(image: UIImage, named: String) {
        print("\nfunc saveUIImage(image: UIImage, named: String)...")
        guard
            let data = image.pngData() else { print("Error getting data.\n")
            return 
        }
        guard
            let fileSavePath = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
//                .appendingPathComponent("MyImages", isDirectory: true)
                .appendingPathComponent("\(LocalFileManager.vm.imageName)") else {
            print("Error getting fileSavePath.\n")
            return
        }
        do {
            try data.write(to: fileSavePath)
//            filePathSet.insert(fileSavePath)
            print("Image saved to: \(fileSavePath)")
            print("Success saving image.")
        } catch let error {
            print("Error saving image. \(error)\n")
        }
        filePathSet.insert(fileSavePath)
        print("Success saving image.\n")
    }
    
    func deleteImageFromFileManager(name: String) {
        print("deleteImageFromFileManager() \(name)")
        guard
            let path = getPathForImage(nane: LocalFileManager.vm.imageName),
            Foundation.FileManager.default.fileExists(atPath: path.path) else {
            print("Error getting path.\n")
            return
        }
        print("success deleting image.\n")
        print(path)
        return
    }
    
    func deleteImageFolderFromFileManager() {
        print("deleteImageFolderFromFileManager()")
        
    }
    
    func getPathForImage(nane: String) -> URL? {
        guard
            let path = Foundation.FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("\(LocalFileManager.vm.imageName)") else { 
            print("Error getting path.\n")
            return nil
        }
        return path
    }
    
    func getImage(name: String) -> UIImage? {
        guard
            let fileSavePath = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("\(LocalFileManager.vm.imageName)") else {
            print("Error getting fileSavePath.\n")
            return nil
        }
        return UIImage(contentsOfFile: fileSavePath.absoluteString)
    }
}
