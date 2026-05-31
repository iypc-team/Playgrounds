// BookmarkManager.swift
// 

import Foundation

struct BookmarkManager {
    static let bookmarkKey = "iCloudDocumentBookmark"
    
    static func saveBookmark(for url: URL) {
        do {
            let data = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey: bookmarkKey)
        } catch {
            print("Error saving bookmark: \(error.localizedDescription)")
        }
    }
    
    static func restoreURL() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("Bookmark is stale; clearing.")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            
            // Verify file exists at the path
            if !FileManager.default.fileExists(atPath: url.path) {
                print("File no longer exists at: \(url.path)")
                return nil
            }
            
            return url
        } catch {
            print("Error resolving bookmark: \(error.localizedDescription)")
            return nil
        }
    }
}
