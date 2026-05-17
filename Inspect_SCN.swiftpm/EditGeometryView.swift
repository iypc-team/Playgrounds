//  EditGeometryView.swift
//  

import SwiftUI
import SceneKit

struct EditGeometryView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    
    @State private var report: String = ""
    @State private var showReport: Bool = false
    @State private var showBoundingBox: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            SceneKitView(scene: viewModel.scene, sceneModel: viewModel.sceneModel)
                .id(viewModel.sceneRevision)
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 12) {
                
                Text(viewModel.selectedFile)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    controlButton("Inspect", systemImage: "magnifyingglass", color: .teal) {
                        report = viewModel.sceneModel.generateInspectionReport(for: viewModel.selectedFile)
                        viewModel.sceneModel.printGeometrySummary()
                        showReport = true
                    }
                    
                    controlButton(
                        showBoundingBox ? "Hide BBox" : "Show BBox",
                        systemImage: showBoundingBox ? "cube.transparent.fill" : "cube.transparent",
                        color: showBoundingBox ? .red : .blue
                    ) {
                        toggleBoundingBox()
                    }
                }
                
                if showReport && !report.isEmpty {
                    inlineReport(title: "Geometry", content: report) { showReport = false }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .navigationTitle("Edit Geometry")
        .navigationBarTitleDisplayMode(.inline)
        // Remove bounding box when leaving screen
        .onDisappear {
            removeBoundingBox()
        }
    }
    
    // MARK: - Bounding Box
    
    private func toggleBoundingBox() {
        showBoundingBox.toggle()
        if showBoundingBox {
            if let node = viewModel.sceneModel.createBoundingBoxNode() {
                viewModel.scene.rootNode.addChildNode(node)
            }
        } else {
            removeBoundingBox()
        }
    }
    
    private func removeBoundingBox() {
        viewModel.scene.rootNode
            .childNode(withName: "boundingBox", recursively: true)?
            .removeFromParentNode()
        showBoundingBox = false
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
                Image(systemName: systemImage).font(.title3)
                Text(title).font(.caption.weight(.semibold))
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

struct EditGeometryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditGeometryView().environmentObject(SceneViewModel())
        }
    }
}
