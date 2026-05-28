// iCloud Drive 05/28/2026-3
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Drive.swiftpm
// 

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = iCloudDriveManager()
    
    @State private var showingNewFileSheet = false
    @State private var newFileName: String = ""
    @State private var newFileContent: String = ""
    @State private var selectedFileURL: URL? = nil
    @State private var showingPreview = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if manager.iCloudFiles.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("No files in iCloud Drive")
                            .font(.title2)
                        Text("Files saved here will appear automatically across devices.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(manager.iCloudFiles, id: \.self) { url in
                            Button {
                                selectedFileURL = url
                                showingPreview = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(.blue)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(url.lastPathComponent)
                                            .font(.headline)
                                        HStack {
                                            Text(manager.fileSizeString(for: url))
                                            Text("•")
                                            Text(manager.fileModificationDate(for: url))
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    manager.deleteFile(at: url)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    manager.resolveConflicts(for: url)
                                } label: {
                                    Label("Resolve Conflicts", systemImage: "arrow.triangle.2.circlepath")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("iCloud Drive")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        manager.listFiles()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingNewFileSheet = true
                    } label: {
                        Label("New File", systemImage: "square.and.pencil")
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Status Messages
                VStack {
                    if let error = manager.errorMessage {
                        HStack {
                            Text(error)
                                .foregroundStyle(.red)
                            Spacer()
                            Button("Dismiss") { manager.clearMessages() }
                        }
                        .padding()
                        .background(.red.opacity(0.1))
                    }
                    
                    if let success = manager.successMessage {
                        HStack {
                            Text(success)
                                .foregroundStyle(.green)
                            Spacer()
                            Button("Dismiss") { manager.clearMessages() }
                        }
                        .padding()
                        .background(.green.opacity(0.1))
                    }
                }
            }
        }
        // MARK: - New File Sheet
        .sheet(isPresented: $showingNewFileSheet) {
            NavigationStack {
                Form {
                    Section("File Details") {
                        TextField("File name", text: $newFileName)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        TextField("Content", text: $newFileContent, axis: .vertical)
                            .frame(minHeight: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .navigationTitle("New Text File")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            resetNewFileForm()
                            showingNewFileSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if !newFileName.isEmpty {
                                let finalName = newFileName.hasSuffix(".txt") ? newFileName : "\(newFileName).txt"
                                manager.saveTextFile(fileName: finalName, content: newFileContent)
                                resetNewFileForm()
                                showingNewFileSheet = false
                            }
                        }
                        .disabled(newFileName.isEmpty)
                    }
                }
            }
        }
        // MARK: - File Preview Sheet
        .sheet(isPresented: $showingPreview) {
            if let url = selectedFileURL {
                FilePreviewView(url: url)
            }
        }
        .onAppear {
            manager.listFiles()
        }
    }
    
    private func resetNewFileForm() {
        newFileName = ""
        newFileContent = ""
    }
}

// MARK: - Simple File Preview
struct FilePreviewView: View {
    let url: URL
    
    @State private var content: String = "Loading..."
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(url.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Just dismiss
                    }
                }
            }
            .onAppear {
                loadFileContent()
            }
        }
    }
    
    private func loadFileContent() {
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            content = "Could not read file: \(error.localizedDescription)"
        }
    }
}
