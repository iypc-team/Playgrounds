// SKEdit 06/05/2026-6
// ContentView.swift
// SKEdit - Updated with .scn → .usdz conversion + RealityKit preview
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/SKEdit.swiftpm. 

import SwiftUI
import SceneKit
import RealityKit
import UniformTypeIdentifiers

// MARK: - SceneKit .scn UTType
private extension UTType {
    /// com.apple.scenekit.scene → fallback to filename extension
    static let scnScene: UTType =
    UTType("com.apple.scenekit.scene")
    ?? UTType(filenameExtension: "scn")
    ?? .data
}

struct ContentView: View {
    @StateObject private var documentManager = DocumentManager()
    @State private var selectedURL: URL?
    @State private var cameraNode: SCNNode?
    @State private var isFilePickerPresented = false
    @State private var showMetadata = false
    
    // NEW: USDZ conversion & preview states
    @State private var convertedUSDZURL: URL?
    @State private var showRealityKit = false
    
    private let allowedTypes: [UTType] = [.scnScene]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Error Banner
                if let error = documentManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.primary)
                        Spacer()
                        Button {
                            documentManager.errorMessage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.15))
                }
                
                // MARK: - Main Content
                ZStack {
                    if documentManager.isLoading {
                        ProgressView("Loading…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else if showRealityKit, let usdzURL = convertedUSDZURL {
                        RealityKitView(usdzURL: usdzURL)
                        
                    } else if let scene = documentManager.scene {
                        SceneKitView(scene: scene, cameraNode: $cameraNode)
                        
                    } else {
                        // Empty / welcome state
                        VStack(spacing: 20) {
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 60))
                                .foregroundStyle(.teal)
                            Text("SKEdit")
                                .font(.title.bold())
                            Text("Open a .scn file to begin")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Open .scn File") {
                                isFilePickerPresented = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.teal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                // MARK: - Metadata Panel
                if showMetadata, let metadata = documentManager.fileMetadata {
                    Divider()
                    ScrollView {
                        FileMetadataView(metadata: metadata)
                            .padding()
                    }
                    .frame(maxHeight: 240)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle(documentManager.fileMetadata?.name ?? "SKEdit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading: Open + Info
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        isFilePickerPresented = true
                    } label: {
                        Label("Open", systemImage: "folder")
                    }
                    
                    if selectedURL != nil {
                        Button {
                            withAnimation { showMetadata.toggle() }
                        } label: {
                            Label("Info", systemImage: "info.circle")
                        }
                    }
                }
                
                // Trailing: Convert + Save + Close
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if documentManager.isSaving {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } 
                    else if let scene = documentManager.scene, !showRealityKit {
                        Button("Convert to USDZ") {
                            Task {
                                await convertToUSDZ()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if let url = selectedURL, documentManager.scene != nil, !showRealityKit {
                        Button {
                            Task { await saveFile(to: url) }
                        } label: {
                            Label("Save SCN", systemImage: "square.and.arrow.down")
                        }
                    }
                    
                    if selectedURL != nil {
                        Button(role: .destructive) {
                            resetToSceneMode()
                        } label: {
                            Label("Close", systemImage: "xmark.circle")
                        }
                    }
                }
            }
            // MARK: - File Picker
            .background {
                DocumentPickerView(
                    isPresented: $isFilePickerPresented,
                    allowedContentTypes: allowedTypes
                ) { url in
                    selectedURL = url
                    BookmarkManager.saveBookmark(for: url)
                    Task { await loadFile(from: url) }
                }
            }
            // MARK: - Restore bookmark on launch
            .onAppear {
                if let restoredURL = BookmarkManager.restoreURL() {
                    selectedURL = restoredURL
                    Task { await loadFile(from: restoredURL) }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func loadFile(from url: URL) async {
        do {
            try await documentManager.loadFile(from: url)
        } catch {
            documentManager.errorMessage = "Load failed: \(error.localizedDescription)"
        }
    }
    
    private func saveFile(to url: URL) async {
        do {
            try await documentManager.saveFile(to: url)
        } catch {
            documentManager.errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
    
    // NEW: Convert SCNScene to USDZ
    private func convertToUSDZ() async {
        guard let scene = documentManager.scene, let originalURL = selectedURL else { return }
        
        documentManager.isLoading = true
        defer { documentManager.isLoading = false }
        
        let usdzName = originalURL.deletingPathExtension().lastPathComponent + ".usdz"
        let tempDir = FileManager.default.temporaryDirectory
        let usdzURL = tempDir.appendingPathComponent(usdzName)
        
        do {
            let success = scene.write(to: usdzURL, options: nil, delegate: nil, progressHandler: nil)
            guard success else {
                throw NSError(domain: "ConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Scene write failed"])
            }
            
            convertedUSDZURL = usdzURL
            showRealityKit = true
            documentManager.errorMessage = nil
        } catch {
            documentManager.errorMessage = "Conversion failed: \(error.localizedDescription)"
        }
    }
    
    private func resetToSceneMode() {
        documentManager.clear()
        selectedURL = nil
        showMetadata = false
        convertedUSDZURL = nil
        showRealityKit = false
    }
}

#Preview {
    ContentView()
}
