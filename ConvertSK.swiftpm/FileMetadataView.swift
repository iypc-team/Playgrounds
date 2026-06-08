// FileMetadataView.swift
// 

import SwiftUI

struct FileMetadataView: View {
    let metadata: DocumentManager.FileMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("File Information")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Divider()
            
            Group {
                LabeledContent("Filename", value: metadata.name)
                
                LabeledContent("Type", value: fileType)
                
                LabeledContent("Size", value: formattedSize)
                
                if let creation = metadata.creationDate {
                    LabeledContent("Created", value: creation.formatted(date: .abbreviated, time: .shortened))
                }
                
                if let modification = metadata.modificationDate {
                    LabeledContent("Last Modified", value: modification.formatted(date: .abbreviated, time: .shortened))
                }
                
                LabeledContent("Path", value: metadata.path)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var fileType: String {
        if metadata.name.lowercased().hasSuffix(".scn") {
            return "SceneKit Scene (.scn)"
        } else if metadata.name.lowercased().hasSuffix(".txt") || metadata.name.lowercased().hasSuffix(".swift") {
            return "Text Document"
        } else {
            return "Unknown (\(URL(fileURLWithPath: metadata.name).pathExtension.uppercased()))"
        }
    }
    
    private var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: metadata.size)
    }
}

// Preview
#Preview {
    FileMetadataView(
        metadata: DocumentManager.FileMetadata(
            name: "ExampleScene.scn",
            size: 1_245_678,
            creationDate: Date().addingTimeInterval(-86400),
            modificationDate: Date(),
            path: "/iCloud Drive/Documents/ExampleScene.scn"
        )
    )
    .padding()
}


