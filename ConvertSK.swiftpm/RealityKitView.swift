// RealityKitView.swift  (iOS 16.6 compatible)
// 

import SwiftUI
import RealityKit

struct RealityKitView: View {
    let usdzURL: URL
    
    @State private var errorMessage: String?
    @State private var isSaving = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ARViewContainer(usdzURL: usdzURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            
            Button {
                Task { await saveToICloud() }
            } label: {
                Label("Save to iCloud Drive / USDZ FILES", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSaving)
        }
        .navigationTitle("USDZ Preview")
    }
    
    private func saveToICloud() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            guard let iCloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                throw NSError(domain: "iCloudError", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud Drive is not available"])
            }
            
            let documentsDir = iCloudContainer.appendingPathComponent("Documents")
            let targetFolder = documentsDir.appendingPathComponent("USDZ FILES")
            
            try FileManager.default.createDirectory(at: targetFolder, withIntermediateDirectories: true)
            
            let destinationURL = targetFolder.appendingPathComponent(usdzURL.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: usdzURL, to: destinationURL)
            
        } catch {
            errorMessage = "Save failed:\n\(error.localizedDescription)"
        }
    }
}
