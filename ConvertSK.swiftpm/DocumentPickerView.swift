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
    
    // ✅ Transparent container VC — the picker is presented FROM this container
    //    in updateUIViewController, avoiding the UIKit presentation-hierarchy crash.
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController,
                                context: Context) {
        if isPresented {
            guard uiViewController.presentedViewController == nil else { return }
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: allowedContentTypes
            )
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            picker.directoryURL = Self.playgroundsDirectoryURL
            uiViewController.present(picker, animated: true)
        } else {
            uiViewController.presentedViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - iCloud Playgrounds Directory Resolution
    static var playgroundsDirectoryURL: URL? {
        let fm = FileManager.default
        
        if let ownContainer = fm.url(forUbiquityContainerIdentifier: nil) {
            let mobileDocuments = ownContainer.deletingLastPathComponent()
            return mobileDocuments
                .appendingPathComponent("iCloud~com~apple~Playgrounds")
                .appendingPathComponent("Documents")
        }
        
        if let container = fm.url(
            forUbiquityContainerIdentifier: "iCloud.com.apple.Playgrounds"
        ) {
            let docs = container.appendingPathComponent("Documents")
            return fm.fileExists(atPath: docs.path) ? docs : container
        }
        
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
            isPresented = false
            // ✅ Secondary validation: silently ignore any non-.scn selection.
            guard let url = urls.first,
                  url.pathExtension.lowercased() == "scn" else { return }
            onPick(url)
        }
        
        func documentPickerWasCancelled(
            _ controller: UIDocumentPickerViewController
        ) {
            isPresented = false
        }
    }
}
