//  iCloud Editor 05/31/2026-2
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Editor.swiftpm
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = DocumentManager()
    @State private var showingImporter = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                TextEditor(text: $manager.documentData)
                    .border(Color.secondary.opacity(0.5))
                    .padding()
                
                Button("Save Changes") {
                    guard let savedURL = BookmarkManager.restoreURL() else { 
                        errorMessage = "No file active. Please open a file."
                        return 
                    }
                    Task {
                        do {
                            try await manager.saveFile(data: manager.documentData, to: savedURL)
                            self.errorMessage = nil
                        } catch {
                            self.errorMessage = "Save failed: \(error.localizedDescription)"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("iCloud Editor")
            .toolbar { Button("Open") { showingImporter = true } }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.plainText]) { result in
                handleFileSelection(result)
            }
            .onAppear { restoreSession() }
        }
    }
    
    private func handleFileSelection(_ result: Result<URL, Error>) {
        if case .success(let url) = result {
            BookmarkManager.saveBookmark(for: url)
            loadData(from: url)
        }
    }
    
    private func restoreSession() {
        if let savedURL = BookmarkManager.restoreURL() {
            loadData(from: savedURL)
        }
    }
    
    private func loadData(from url: URL) {
        Task {
            do {
                manager.documentData = try await manager.loadFile(from: url)
                self.errorMessage = nil
            } catch {
                self.errorMessage = "Load error: \(error.localizedDescription)"
            }
        }
    }
}
