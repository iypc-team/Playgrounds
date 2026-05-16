//  ExportFilesView.swift
//  

import SwiftUI
import SceneKit

struct ExportFilesView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    
    @State private var exportFormat: String = "usdz"
    @State private var exportedURL: URL? = nil
    @State private var showSuccess: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .id(viewModel.sceneRevision)
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 16) {
                
                Text(viewModel.selectedFile)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Format picker
                VStack(spacing: 6) {
                    Text("Export Format")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Picker("Format", selection: $exportFormat) {
                        Text("USDZ").tag("usdz")
                        Text("SCN").tag("scn")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                
                // Export button
                Button(action: performExport) {
                    Label(
                        "Export as \(exportFormat.uppercased())",
                        systemImage: "square.and.arrow.up.fill"
                    )
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(12)
                }
                
                // Success banner
                if showSuccess, let url = exportedURL {
                    VStack(spacing: 6) {
                        Label("Export Successful", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(url.lastPathComponent)
                            .font(.caption.monospaced())
                        
                        Text("Documents/Exports/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Copy Full Path") {
                            UIPasteboard.general.string = url.path
                        }
                        .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .navigationTitle("Export Files")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func performExport() {
        showSuccess = false
        if let url = viewModel.exportScene(as: viewModel.selectedFile, format: exportFormat) {
            exportedURL = url
            showSuccess = true
        }
    }
}

struct ExportFilesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExportFilesView().environmentObject(SceneViewModel())
        }
    }
}

