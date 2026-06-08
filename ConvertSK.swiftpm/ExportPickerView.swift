// ExportPickerView.swift
// SKEdit – wraps UIDocumentPickerViewController in export mode.
// Presents the iOS "Save to Files" sheet so the user chooses the save location.

import SwiftUI
import UIKit

struct ExportPickerView: UIViewControllerRepresentable {
    
    /// Set to a temp file URL to trigger the sheet; nil to dismiss.
    @Binding var exportURL: URL?
    
    /// Called on completion. `savedURL` is the destination on success, nil on cancel.
    let onSaved: (URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(exportURL: $exportURL, onSaved: onSaved)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController,
                                context: Context) {
        if let url = exportURL {
            guard uiViewController.presentedViewController == nil else { return }
            let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
            picker.delegate = context.coordinator
            // Suggest the user's existing USDZ Files folder as the opening directory.
            picker.directoryURL = Self.suggestedDirectoryURL
            uiViewController.present(picker, animated: true)
        } else {
            uiViewController.presentedViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - Suggested initial directory
    
    /// Walks known iCloud container paths looking for an existing "USDZ Files" folder.
    /// Falls back to the iCloud Drive root (or nil) so the picker still opens in Files.
    static var suggestedDirectoryURL: URL? {
        let fm = FileManager.default
        
        // Path 1 — app's own ubiquity container.
        // When running inside Swift Playgrounds this IS the Playgrounds container.
        if let container = fm.url(forUbiquityContainerIdentifier: nil) {
            
            // Sibling path: …/Mobile Documents/iCloud~com~apple~Playgrounds/Documents/USDZ Files
            let mobileDocuments = container.deletingLastPathComponent()
            let playgroundsUSDZ = mobileDocuments
                .appendingPathComponent("iCloud~com~apple~Playgrounds")
                .appendingPathComponent("Documents")
                .appendingPathComponent("USDZ Files")
            if fm.fileExists(atPath: playgroundsUSDZ.path) { return playgroundsUSDZ }
            
            // Container's own Documents/USDZ Files
            let containerUSDZ = container
                .appendingPathComponent("Documents")
                .appendingPathComponent("USDZ Files")
            if fm.fileExists(atPath: containerUSDZ.path) { return containerUSDZ }
            
            // Fall back to the container root so the picker opens inside iCloud Drive
            return container
        }
        
        // Path 2 — explicit Playgrounds container identifier
        if let container = fm.url(
            forUbiquityContainerIdentifier: "iCloud.com.apple.Playgrounds"
        ) {
            let usdzDir = container
                .appendingPathComponent("Documents")
                .appendingPathComponent("USDZ Files")
            return fm.fileExists(atPath: usdzDir.path) ? usdzDir : container
        }
        
        return nil  // picker opens at the default Files app location
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var exportURL: URL?
        let onSaved: (URL?) -> Void
        
        init(exportURL: Binding<URL?>, onSaved: @escaping (URL?) -> Void) {
            _exportURL = exportURL
            self.onSaved = onSaved
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            exportURL = nil
            onSaved(urls.first)
        }
        
        func documentPickerWasCancelled(
            _ controller: UIDocumentPickerViewController
        ) {
            exportURL = nil
            onSaved(nil)
        }
    }
}

