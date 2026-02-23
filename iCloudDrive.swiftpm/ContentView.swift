//  iCloudDrive 02/22/2026-5
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm

//  ContentView.swift
//  iCloudDrive Playground - ContentView with .fileImporter
//  Updated: 2026-02-22

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingPicker = false
    @State private var pickedURLs: [URL] = []
    @State private var previewText: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Pick files from iCloud Drive") {
                    showingPicker = true
                }
                .padding()
                
                List {
                    Section(header: Text("Picked files")) {
                        if pickedURLs.isEmpty {
                            Text("No files selected").foregroundColor(.secondary)
                        } else {
                            ForEach(pickedURLs, id: \.self) { url in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(url.lastPathComponent).font(.headline)
                                    Text(url.path).font(.caption).foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Section(header: Text("Preview")) {
                        ScrollView {
                            Text(previewText.isEmpty ? "No preview available" : previewText)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                        .frame(minHeight: 120)
                    }
                    
                    if let errorMessage = errorMessage {
                        Section {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("iCloud Drive Picker")
        }
        .fileImporter(
            isPresented: $showingPicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                // store selected URLs for UI
                pickedURLs = urls
                
                // read the first file for a quick preview
                if let first = urls.first {
                    readFileForPreview(url: first)
                } else {
                    previewText = ""
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func readFileForPreview(url: URL) {
        // For files from the system picker, use security-scoped access when available.
        let didStart = url.startAccessingSecurityScopedResource()
        defer {
            if didStart { url.stopAccessingSecurityScopedResource() }
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Try to interpret as UTF-8 text for preview
            if let text = String(data: data, encoding: .utf8) {
                // Limit preview size so very large files don't blow up the UI
                let maxPreviewChars = 20_000
                if text.count > maxPreviewChars {
                    let prefix = text.prefix(maxPreviewChars)
                    previewText = String(prefix) + "\n\n--- Preview truncated ---"
                } else {
                    previewText = text
                }
            } else {
                // Non-text data: show metadata instead
                previewText = "Binary file — \(data.count) bytes"
            }
            errorMessage = nil
            
            // Optional: create and persist a security-scoped bookmark to resume access later.
            // Note: persistence across Playground restarts may be unreliable.
            /*
             let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
             UserDefaults.standard.set(bookmark, forKey: "bookmark_\(url.lastPathComponent)")
             */
            
        } catch {
            previewText = ""
            errorMessage = error.localizedDescription
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
