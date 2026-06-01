//  iCloud Editor 06/01/2026-5
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Editor.swiftpm

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = DocumentManager()
    @State private var showingImporter = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Editor
                TextEditor(text: $manager.documentData)
                    .font(.body.monospaced())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))          // Fix #4
                
                // Metadata Panel
                if let metadata = manager.fileMetadata {
                    FileMetadataView(metadata: metadata)
                } else {
                    Text("No file loaded")
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    Button("Open from iCloud") {
                        showingImporter = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Save") {
                        Task { await saveDocument() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(                                              // Fix #5
                        manager.currentURL == nil ||
                        manager.isSaving ||
                        manager.isLoading
                    )
                }
            }
            .padding()
            .navigationTitle(manager.currentURL?.lastPathComponent ?? "iCloud Editor")  // Fix #2
            .overlay {
                if manager.isLoading || manager.isSaving {
                    ProgressView(manager.isLoading ? "Loading..." : "Saving...")
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.plainText, .text]
            ) { result in
                handleFileSelection(result)
            }
            .alert("Error", isPresented: Binding(                          // Fix #1
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
                                                )) {
                                                    Button("OK") { errorMessage = nil }
                                                } message: {
                                                    Text(errorMessage ?? "")
                                                }
                                                .onAppear { restoreSession() }
        }
    }
    
    // MARK: - File Handling
    
    private func handleFileSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            manager.currentURL = url                                       // Fix #2
            BookmarkManager.saveBookmark(for: url)
            Task {
                do {
                    try await manager.loadFile(from: url)                  // Fix #3
                } catch {
                    errorMessage = "Failed to load file: \(error.localizedDescription)"
                }
            }
        case .failure(let error):
            errorMessage = "Failed to select file: \(error.localizedDescription)"
        }
    }
    
    private func saveDocument() async {
        guard let url = manager.currentURL,                                // Fix #2
              !manager.documentData.isEmpty else { return }                // Fix #7
        do {
            try await manager.saveFile(data: manager.documentData, to: url)
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
    
    private func restoreSession() {
        if let restoredURL = BookmarkManager.restoreURL() {
            manager.currentURL = restoredURL                               // Fix #2
            Task {
                do {
                    try await manager.loadFile(from: restoredURL)          // Fix #3
                } catch {
                    errorMessage = "Failed to restore session: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //            .preferredColorScheme(.dark)
    }
}
