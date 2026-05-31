//  iCloud Editor 05/31/2026-3
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Editor.swiftpm
//  

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = DocumentManager()
    @State private var showingImporter = false
    @State private var errorMessage: String?
    @State private var currentURL: URL?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Metadata Display
                if let metadata = manager.fileMetadata {
                    FileMetadataView(metadata: metadata)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                TextEditor(text: $manager.documentData)
                    .font(.body.monospaced())
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemBackground))
                    .border(Color.secondary.opacity(0.3))
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button("Open from iCloud") {
                        showingImporter = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button(manager.isSaving ? "Saving..." : "Save Now") {
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(manager.isSaving || manager.documentData.isEmpty)
                }
                .padding(.horizontal)
            }
            .navigationTitle("iCloud Editor")
            .overlay {
                if manager.isLoading {
                    ProgressView("Loading from iCloud...")
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .fileImporter(isPresented: $showingImporter, 
                          allowedContentTypes: [.plainText, .text]) { result in
                handleFileSelection(result)
            }
                          .onAppear { restoreSession() }
        }
    }
    
    private func handleFileSelection(_ result: Result<URL, Error>) {
        if case .success(let url) = result {
            BookmarkManager.saveBookmark(for: url)
            currentURL = url
            loadData(from: url)
        }
    }
    
    private func restoreSession() {
        if let savedURL = BookmarkManager.restoreURL() {
            currentURL = savedURL
            loadData(from: savedURL)
        }
    }
    
    private func loadData(from url: URL) {
        Task {
            do {
                manager.documentData = try await manager.loadFile(from: url)
                errorMessage = nil
            } catch {
                errorMessage = "Load failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveChanges() {
        guard let url = currentURL else {
            errorMessage = "No file is open."
            return
        }
        
        Task {
            do {
                try await manager.saveFile(data: manager.documentData, to: url)
                errorMessage = nil
            } catch {
                errorMessage = "Save failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Metadata View
struct FileMetadataView: View {
    let metadata: DocumentManager.FileMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("📄 \(metadata.name)")
                .font(.headline)
            
            HStack {
                Text("Size: \(formatBytes(metadata.fileSize))")
                Spacer()
                Text("Modified: \(metadata.lastModified?.formatted() ?? "Unknown")")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            HStack {
                Text("iCloud:")
                Text(metadata.iCloudStatus)
                    .foregroundStyle(metadata.isDownloaded ? .green : .orange)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024
        if kb < 1024 { return String(format: "%.1f KB", kb) }
        return String(format: "%.1f MB", kb / 1024)
    }
}
