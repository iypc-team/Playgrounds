// BookmarkManager.swift
// 

import Foundation

struct BookmarkManager {
    static let bookmarkKey = "iCloudDocumentBookmark"
    
    static func saveBookmark(for url: URL) {
        do {
            // In BookmarkManager.swift, 'withSecurityScope' is unavailable in iOS.
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(data, forKey: bookmarkKey)
        } catch {
            print("Failed to save bookmark: \(error.localizedDescription)")
        }
    }
    
    static func restoreURL() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            
            if isStale || !FileManager.default.fileExists(atPath: url.path) {
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            return url
        } catch {
            print("Failed to restore bookmark: \(error.localizedDescription)")
            return nil
        }
    }
}
