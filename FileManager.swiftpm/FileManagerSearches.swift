
import SwiftUI
import Foundation

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    
    var isMP3: Bool { typeIdentifier == "public.mp3" }
    
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
    
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}

extension  FileManager {
    class func cachesURL() -> URL? {
        let paths = Foundation.FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths.first
    }
    
    //  allRecordedCachesData
    func allRecordedCachesData() -> [URL]? {
        print("\nfunc allRecordedCachesData() ")
        if let documentsUrl =  FileManager.cachesURL() {
            do {
                let cachesContent = try Foundation.FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                print("cachesContent: \(cachesContent.description)")
                print()
                //                return cachesContent.filter{ $0.pathExtension == "m4a" }
                return cachesContent
            } catch let error {
                print("allRecordedData() error: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}

extension FileManager {
    class func documentsURL() -> URL? {
        let paths = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    func allDocumentsDirectoryData() -> [URL]? {
        print("\nfunc allDocumentsDirectoryData()")
        if let documentsUrl =  FileManager.documentsURL() {
            do {
                let directoryContents = try Foundation.FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                print("directoryContents: \(directoryContents.description)")
                print()
                
                return directoryContents
            } catch let error {
                print("allRecordedData() error: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}

extension FileManager {
    class func tempURL() -> URL? {
        let paths = Foundation.FileManager.default.temporaryDirectory
        return paths // .first
    }
    // documentsUrl
    func allTemporaryDirectoryData() -> [URL]? {
        print("\nfunc allTemporaryDirectoryData()")
        if let tempFiles =  FileManager.tempURL() {
            do {
                let directoryContents = try Foundation.FileManager.default.contentsOfDirectory(at: tempFiles, includingPropertiesForKeys: nil)
                print("directoryContents: \(directoryContents.description)")
                print()
                
                return directoryContents
            } catch let error {
                print("allRecordedData() error: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}
