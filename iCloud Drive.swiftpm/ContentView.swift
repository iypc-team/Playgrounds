// iCloud Drive 05/28/2026-2
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Drive.swiftpm

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = iCloudDriveManager()
    
    @State private var newFileName: String = ""
    @State private var newFileContent: String = ""
    @State private var showSaveForm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // MARK: - Status Messages
                if let error = manager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.icloud.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                        Spacer()
                        Button(action: { manager.clearMessages() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                }
                
                if let success = manager.successMessage {
                    HStack {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(.green)
                        Text(success)
                            .font(.footnote)
                            .foregroundColor(.green)
                        Spacer()
                        Button(action: { manager.clearMessages() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                }
                
                // MARK: - File List
                if manager.iCloudFiles.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "icloud")
                            .font(.system(size: 60))
                            .foregroundColor(.mint)
                        Text("No files found in iCloud Drive.")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(manager.iCloudFiles, id: \.self) { file in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.mint)
                                Text(file.lastPathComponent)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                            HStack {
                                Text(manager.fileSizeString(for: file))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(manager.fileModificationDate(for: file))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Save Form
                if showSaveForm {
                    VStack(spacing: 12) {
                        Divider()
                        Text("Save New File")
                            .font(.headline)
                        
                        TextField("File name (e.g. notes.txt)", text: $newFileName)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        
                        TextEditor(text: $newFileContent)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                showSaveForm = false
                                newFileName = ""
                                newFileContent = ""
                            }) {
                                Label("Cancel", systemImage: "xmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            
                            Button(action: {
                                guard !newFileName.isEmpty else { return }
                                manager.saveTextFile(
                                    fileName: newFileName,
                                    content: newFileContent
                                )
                                showSaveForm = false
                                newFileName = ""
                                newFileContent = ""
                            }) {
                                Label("Save", systemImage: "icloud.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                            .disabled(newFileName.isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground))
                }
                
                // MARK: - Bottom Toolbar
                Divider()
                HStack(spacing: 16) {
                    Button(action: {
                        manager.listFiles()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise.icloud")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    
                    Button(action: {
                        showSaveForm.toggle()
                    }) {
                        Label("New File", systemImage: "doc.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)
                }
                .padding()
            }
            .navigationTitle("iCloud Drive")
            .onAppear {
                manager.listFiles()
            }
        }
    }
}
