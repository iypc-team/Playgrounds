// USDZConverter.swift
// SKEdit – converts a loaded SCNScene to .usdz and saves to iCloud Drive / USDZ Files.

import Foundation
import SceneKit
import ModelIO
import SceneKit.ModelIO  // Explicit bridge: unlocks MDLAsset(scnScene:) on iOS

// MARK: - Error Type

enum USDZConversionError: LocalizedError {
    case noSceneLoaded
    case formatUnsupported
    case directoryCreationFailed(String)
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .noSceneLoaded:
            return "No scene is currently loaded."
        case .formatUnsupported:
            return "USDZ export is not supported on this device."
        case .directoryCreationFailed(let msg):
            return "Could not create 'USDZ Files' folder: \(msg)"
        case .exportFailed:
            return "USDZ export failed. Ensure the scene contains visible geometry."
        }
    }
}

// MARK: - Converter

struct USDZConverter {
    
    /// Converts `scene` to a `.usdz` file and saves it to
    /// `iCloud Drive / … / USDZ Files / <sourceName>.usdz`.
    ///
    /// - Parameters:
    ///   - scene:      The `SCNScene` to convert.
    ///   - sourceName: Original `.scn` filename; the extension is replaced with `.usdz`.
    /// - Returns:      The `URL` of the written `.usdz` file.
    /// - Throws:       `USDZConversionError`
    static func convert(scene: SCNScene, sourceName: String) throws -> URL {
        // 1 – Confirm USDZ export is available on this device
        guard MDLAsset.canExportFileExtension("usdz") else {
            throw USDZConversionError.formatUnsupported
        }
        
        // 2 – Resolve (and create if needed) the output directory
        let outputDir = try resolveOutputDirectory()
        
        // 3 – Build destination URL
        let baseName = (sourceName as NSString).deletingPathExtension
        let destURL  = outputDir.appendingPathComponent(baseName + ".usdz")
        
        // 4 – Remove a stale copy if one already exists
        let fm = FileManager.default
        if fm.fileExists(atPath: destURL.path) {
            try fm.removeItem(at: destURL)
        }
        
        // 5 – SCNScene → MDLAsset (via SceneKit.ModelIO bridge) → USDZ
        //     export(to:) is Void on iOS 16.6; do NOT capture its return value.
        //     Verify success by confirming the output file was written to disk.
        let asset = MDLAsset(scnScene: scene)
        try asset.export(to: destURL)
        
        guard fm.fileExists(atPath: destURL.path) else {
            throw USDZConversionError.exportFailed
        }
        
        return destURL
    }
    
    // MARK: - Private
    
    /// Returns the `USDZ Files` directory inside the app's iCloud ubiquity-container
    /// Documents folder, creating it if necessary. Falls back to local Documents when
    /// iCloud is unavailable.
    private static func resolveOutputDirectory() throws -> URL {
        let fm = FileManager.default
        
        let base: URL
        if let container = fm.url(forUbiquityContainerIdentifier: nil) {
            base = container.appendingPathComponent("Documents")
        } else {
            // iCloud unavailable – use local Documents
            base = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        let usdzDir = base.appendingPathComponent("USDZ Files")
        do {
            try fm.createDirectory(at: usdzDir,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch {
            throw USDZConversionError.directoryCreationFailed(error.localizedDescription)
        }
        return usdzDir
    }
}
