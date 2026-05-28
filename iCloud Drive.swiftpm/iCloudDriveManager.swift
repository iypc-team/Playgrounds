// iCloud Drive 05/28/2026-1
// iCloudDriveManager.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Drive.swiftpm

import SwiftUI
import Foundation

// MARK: - iCloudDriveManager
class iCloudDriveManager: ObservableObject {
    
    @Published var iCloudFiles: [URL] = []
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    // MARK: - iCloud Documents URL
    var iCloudDocumentsURL: URL? {
        return FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
    
    // MARK: - Check iCloud Availability
    var iCloudAvailable: Bool {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
    }
    
    // MARK: - List Files in iCloud Drive
    func listFiles() {
        guard iCloudAvailable else {
            DispatchQueue.main.async {
                self.errorMessage = "iCloud Drive is not available on this device."
            }
            return
        }
        
        guard let iCloudURL = iCloudDocumentsURL else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not access iCloud Documents directory."
            }
            return
        }
        
        // Create Documents directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: iCloudURL.path) {
            do {
                try FileManager.default.createDirectory(
                    at: iCloudURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to create iCloud Documents folder: \(error.localizedDescription)"
                }
                return
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: iCloudURL,
                    includingPropertiesForKeys: [
                        .nameKey,
                        .fileSizeKey,
                        .contentModificationDateKey,
                        .isDirectoryKey
                    ],
                    options: .skipsHiddenFiles
                )
                DispatchQueue.main.async {
                    self.iCloudFiles = contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error listing iCloud files: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Write/Save a String to iCloud Drive
    func saveTextFile(fileName: String, content: String) {
        guard iCloudAvailable else {
            DispatchQueue.main.async {
                self.errorMessage = "iCloud Drive is not available on this device."
            }
            return
        }
        
        guard let iCloudURL = iCloudDocumentsURL else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not access iCloud Documents directory."
            }
            return
        }
        
        let fileURL = iCloudURL.appendingPathComponent(fileName)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                DispatchQueue.main.async {
                    self.successMessage = "'\(fileName)' saved to iCloud Drive."
                    self.errorMessage = nil
                    self.listFiles()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save '\(fileName)': \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Write/Save Data to iCloud Drive
    func saveDataFile(fileName: String, data: Data) {
        guard iCloudAvailable else {
            DispatchQueue.main.async {
                self.errorMessage = "iCloud Drive is not available on this device."
            }
            return
        }
        
        guard let iCloudURL = iCloudDocumentsURL else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not access iCloud Documents directory."
            }
            return
        }
        
        let fileURL = iCloudURL.appendingPathComponent(fileName)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try data.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async {
                    self.successMessage = "'\(fileName)' saved to iCloud Drive."
                    self.errorMessage = nil
                    self.listFiles()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save '\(fileName)': \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Get File Size String
    func fileSizeString(for url: URL) -> String {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
            }
        } catch {}
        return "Unknown size"
    }
    
    // MARK: - Get File Modification Date String
    func fileModificationDate(for url: URL) -> String {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey])
            if let date = resourceValues.contentModificationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
        } catch {}
        return "Unknown date"
    }
    
    // MARK: - Clear Messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
