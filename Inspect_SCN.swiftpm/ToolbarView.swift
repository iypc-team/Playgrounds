//  ToolbarView.swift
//  Inspect_SCN.swiftpm

import SwiftUI

struct ToolbarView: View {
    @Binding var selectedFile: String
    @Binding var showBoundingBox: Bool
    
    let resourceFiles: [String]
    
    // Actions
    let onInspectGeometry: () -> Void
    let onListMaterials: () -> Void
    let onSetDoubleSided: () -> Void
    let onSetVeryReflective: () -> Void
    let onBoundingBoxToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            
            filePickerMenu
            toolbarButton("Inspect Geometry", action: onInspectGeometry)
            toolbarButton("List Materials", action: onListMaterials)
            toolbarButton("Set Double-Sided", action: onSetDoubleSided)
            toolbarButton("Set Very Reflective", action: onSetVeryReflective)
            
            boundingBoxButton
            
            Spacer()
        }
        .padding()
    }
    
    private var filePickerMenu: some View {
        Menu {
            ForEach(resourceFiles, id: \.self) { file in
                Button(file) {
                    selectedFile = file
                }
            }
        } label: {
            Text("Select File: \(selectedFile)")
                .styledToolbarLabel(background: .gray)
            // 'styledToolbarLabel' is inaccessible due to 'fileprivate' protection level.
        }
        .tint(.white)
    }
    
    private var boundingBoxButton: some View {
        Button {
            onBoundingBoxToggle()
        } label: {
            Text(showBoundingBox ? "Hide Bounding Box" : "Show Bounding Box")
                .styledToolbarLabel(background: .blue)
        }
        .tint(.white)
        .accessibilityLabel(showBoundingBox ? "Hide bounding box" : "Show bounding box")
    }
    
    private func toolbarButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .styledToolbarLabel(background: .gray)
        }
        .tint(.white)
    }
}

