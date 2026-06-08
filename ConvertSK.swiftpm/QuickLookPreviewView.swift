// QuickLookPreviewView.swift
// SKEdit – presents a USDZ file using QLPreviewController (object viewer mode).

import SwiftUI
import QuickLook

struct QuickLookPreviewView: UIViewControllerRepresentable {
    
    /// URL of the .usdz file to preview. Set to nil to dismiss.
    @Binding var previewURL: URL?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(previewURL: $previewURL)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController,
                                context: Context) {
        if previewURL != nil {
            guard uiViewController.presentedViewController == nil else { return }
            // Value 'url' was defined but never used; consider replacing with
            
            let previewController          = QLPreviewController()
            previewController.dataSource   = context.coordinator
            previewController.delegate     = context.coordinator
            
            // QLPreviewController presented modally — no AR room backdrop by default
            uiViewController.present(previewController, animated: true)
            
        } else {
            uiViewController.presentedViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        @Binding var previewURL: URL?
        
        init(previewURL: Binding<URL?>) {
            _previewURL = previewURL
        }
        
        // MARK: QLPreviewControllerDataSource
        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            previewURL != nil ? 1 : 0
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            previewURL! as NSURL
        }
        
        // MARK: QLPreviewControllerDelegate
        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            previewURL = nil
        }
    }
}

