// BookmarkManager.swift
// 
// BookmarkManager.swift
import Foundation

struct BookmarkManager {
    static let bookmarkKey = "iCloudDocumentBookmark"
    
    static func saveBookmark(for url: URL) {
        do {
            let options: URL.BookmarkCreationOptions
            
#if os(macOS)
            options = .withSecurityScope
#else
            options = []
#endif
            
            let data = try url.bookmarkData(
                options: options,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            UserDefaults.standard.set(data, forKey: bookmarkKey)
            print("✅ Bookmark saved successfully")
            
        } catch {
            print("Failed to save bookmark: \(error.localizedDescription)")
        }
    }
    
    static func restoreURL() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        
        var isStale = false
        do {
            let options: URL.BookmarkResolutionOptions
            
#if os(macOS)
            options = .withSecurityScope
#else
            options = []
#endif
            
            let url = try URL(resolvingBookmarkData: data,
                              options: options,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("⚠️ Bookmark is stale")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            
            if !FileManager.default.fileExists(atPath: url.path) {
                print("⚠️ Bookmarked file no longer exists")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            
            return url
            
        } catch {
            print("Failed to restore bookmark: \(error.localizedDescription)")
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
            return nil
        }
    }
}
