// FileMetadataView.swift
// 

import SwiftUI

struct FileMetadataView: View {
    let metadata: DocumentManager.FileMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Metadata")
                .font(.headline)
            
            Group {
                LabeledContent("Name", value: metadata.name)
                LabeledContent("Size", value: formatFileSize(metadata.fileSize))
                
                if let date = metadata.lastModified {
                    LabeledContent("Modified", value: date.formatted(date: .abbreviated, time: .shortened))
                }
                
                LabeledContent("iCloud Status", value: metadata.iCloudStatus)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

