//  EditMaterialsView.swift
//  

import SwiftUI
import SceneKit

struct EditMaterialsView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    
    @State private var report: String = ""
    @State private var showReport: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Full-screen 3D preview
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .id(viewModel.sceneRevision)
                .ignoresSafeArea(edges: .bottom)
            
            // Controls docked to bottom
            VStack(spacing: 12) {
                
                Text(viewModel.selectedFile)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    controlButton("List Materials", systemImage: "list.bullet", color: .blue) {
                        report = viewModel.sceneModel.generateMaterialsReport(for: viewModel.selectedFile)
                        showReport = true
                    }
                    controlButton("Double-Sided", systemImage: "square.2.layers.3d", color: .purple) {
                        viewModel.sceneModel.setAllMaterialsDoubleSided()
                    }
                    controlButton("Reflective", systemImage: "circle.hexagongrid.fill", color: .orange) {
                        viewModel.sceneModel.setAllMaterialsVeryReflective()
                    }
                }
                
                if showReport && !report.isEmpty {
                    inlineReport(title: "Materials", content: report) { showReport = false }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .navigationTitle("Edit Materials")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helpers
    
    private func controlButton(
        _ title: String,
        systemImage: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.75))
            .cornerRadius(12)
        }
    }
    
    private func inlineReport(title: String, content: String, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
            ScrollView {
                Text(content)
                    .font(.caption.monospaced())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 150)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EditMaterialsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditMaterialsView().environmentObject(SceneViewModel())
        }
    }
}

