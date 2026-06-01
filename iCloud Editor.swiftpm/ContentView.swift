//  iCloud Editor 06/01/2026-4
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
                // Editor
                TextEditor(text: $manager.documentData)
                    .font(.body.monospaced())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
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
                        Task {
                            await saveDocument()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentURL == nil || manager.isSaving)
                }
            }
            .padding()
            .navigationTitle(currentURL?.lastPathComponent ?? "iCloud Editor")
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
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
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
            currentURL = url
            BookmarkManager.saveBookmark(for: url)
            
            Task {
                do {
                    let content = try await manager.loadFile(from: url)
                    manager.documentData = content
                } catch {
                    errorMessage = "Failed to load file: \(error.localizedDescription)"
                }
            }
            
        case .failure(let error):
            errorMessage = "Failed to select file: \(error.localizedDescription)"
        }
    }
    
    private func saveDocument() async {
        guard let url = currentURL else { return }
        do {
            try await manager.saveFile(data: manager.documentData, to: url)
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
    
    private func restoreSession() {
        if let restoredURL = BookmarkManager.restoreURL() {
            currentURL = restoredURL
            Task {
                do {
                    let content = try await manager.loadFile(from: restoredURL)
                    manager.documentData = content
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
