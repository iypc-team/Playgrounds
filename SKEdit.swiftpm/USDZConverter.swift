// USDZConverter.swift
// SKEdit – converts a loaded SCNScene to a temporary .usdz file.
// The caller presents an ExportPickerView to let the user choose the final save location.

import Foundation
import SceneKit

// MARK: - Error Type

enum USDZConversionError: LocalizedError {
    case noSceneLoaded
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .noSceneLoaded:
            return "No scene is currently loaded."
        case .exportFailed:
            return "USDZ export failed. Ensure the scene contains visible geometry."
        }
    }
}

// MARK: - Converter

struct USDZConverter {
    
    /// Converts `scene` to a `.usdz` file written to the system temporary directory.
    /// Present the returned URL with `ExportPickerView` so the user picks the final location.
    ///
    /// - Parameters:
    ///   - scene:      The `SCNScene` to convert.
    ///   - sourceName: Original `.scn` filename; extension is replaced with `.usdz`.
    /// - Returns:      A temporary `URL` containing the written `.usdz` file.
    /// - Throws:       `USDZConversionError`
    static func convert(scene: SCNScene, sourceName: String) throws -> URL {
        let fm       = FileManager.default
        let baseName = (sourceName as NSString).deletingPathExtension
        let tempURL  = fm.temporaryDirectory.appendingPathComponent(baseName + ".usdz")
        
        // Remove any stale temp copy
        if fm.fileExists(atPath: tempURL.path) {
            try fm.removeItem(at: tempURL)
        }
        
        // SCNScene.write(to:) with a .usdz destination uses SceneKit's built-in
        // USD pipeline — the correct iOS 13+ path. Return value is discardableResult;
        // verify success by confirming the output file exists.
        scene.write(to: tempURL, options: nil, delegate: nil, progressHandler: nil)
        
        guard fm.fileExists(atPath: tempURL.path) else {
            throw USDZConversionError.exportFailed
        }
        
        return tempURL
    }
}
