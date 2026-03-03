// FileManagerSearch.swift
// Utilities to access common directories and inspect URLs safely
// class func 

import Foundation
import UniformTypeIdentifiers

extension URL {
    var typeIdentifier: String? {
        (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    
    var isMP3: Bool {
        if #available(iOS 14.0, *) {
            if let type = typeIdentifier, let ut = UTType(type) {
                return ut.conforms(to: .audio) && pathExtension.lowercased() == "mp3"
            } else {
                return pathExtension.lowercased() == "mp3"
            }
        } else {
            return typeIdentifier == "public.mp3"
        }
    }
    
    var localizedName: String? {
        (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
    
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}

extension FileManager {
    class func cachesURL() -> URL? {
        Foundation.FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func allRecordedCachesData() -> [URL]? {
        guard let caches = FileManager.cachesURL() else { return nil }
        return try? Foundation.FileManager.default.contentsOfDirectory(at: caches, includingPropertiesForKeys: nil)
    }
    
    class func documentsURL() -> URL? {
        Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func allDocumentsDirectoryData() -> [URL]? {
        guard let docs = FileManager.documentsURL() else { return nil }
        return try? Foundation.FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
    }
    
    class func tempURL() -> URL {
        Foundation.FileManager.default.temporaryDirectory
    }
    
    func allTemporaryDirectoryData() -> [URL]? {
        let temp = FileManager.tempURL()
        return try? Foundation.FileManager.default.contentsOfDirectory(at: temp, includingPropertiesForKeys: nil)
    }
}
