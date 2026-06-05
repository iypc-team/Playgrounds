// DocumentPickerView.swift
// 

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onPick: onPick)
    }
    
    // ✅ Return a transparent container VC — NOT UIDocumentPickerViewController itself.
    //    Embedding UIDocumentPickerViewController directly as .sheet content
    //    causes a UIKit presentation-hierarchy crash.
    //    The picker is presented FROM this container in updateUIViewController instead.
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController,
                                context: Context) {
        if isPresented {
            // Guard against double-presentation
            guard uiViewController.presentedViewController == nil else { return }
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: allowedContentTypes
            )
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            picker.directoryURL = Self.playgroundsDirectoryURL
            uiViewController.present(picker, animated: true)
        } else {
            // Dismiss if isPresented was set to false externally
            uiViewController.presentedViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - iCloud Playgrounds Directory Resolution
    //
    // iCloud containers live at:
    //   /private/var/mobile/Library/Mobile Documents/<container-id>/
    //
    // Strategy 1 — navigate up from the app's own iCloud container:
    //   .deletingLastPathComponent() → /…/Mobile Documents/
    //   append iCloud~com~apple~Playgrounds/Documents
    //
    // UIDocumentPickerViewController runs with system-level access and can
    // display this path even though the app sandbox cannot read it directly.
    //
    // Strategy 2 — explicit Playgrounds container ID (requires entitlement).
    // Strategy 3 — local Documents directory final fallback.
    static var playgroundsDirectoryURL: URL? {
        let fm = FileManager.default
        
        // Strategy 1
        if let ownContainer = fm.url(forUbiquityContainerIdentifier: nil) {
            let mobileDocuments = ownContainer.deletingLastPathComponent()
            return mobileDocuments
                .appendingPathComponent("iCloud~com~apple~Playgrounds")
                .appendingPathComponent("Documents")
        }
        
        // Strategy 2
        if let container = fm.url(
            forUbiquityContainerIdentifier: "iCloud.com.apple.Playgrounds"
        ) {
            let docs = container.appendingPathComponent("Documents")
            return fm.fileExists(atPath: docs.path) ? docs : container
        }
        
        // Strategy 3
        return fm.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        let onPick: (URL) -> Void
        
        init(isPresented: Binding<Bool>, onPick: @escaping (URL) -> Void) {
            _isPresented = isPresented
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
            isPresented = false
        }
        
        func documentPickerWasCancelled(
            _ controller: UIDocumentPickerViewController
        ) {
            isPresented = false
        }
    }
}
