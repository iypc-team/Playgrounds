// ConvertSK 06/08/2026-1
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/ConvertSK.swiftpm.

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

// MARK: - SceneKit .scn UTType
private extension UTType {
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
    @State private var showMetadata          = false
    @State private var convertSuccessBanner: String?
    @State private var usdzTempURL: URL?         // triggers ExportPickerView
    @State private var usdzPreviewURL: URL?      // ← NEW: triggers QuickLookPreviewView
    
    private let allowedTypes: [UTType] = [.scnScene]
    
    private var isBusy:   Bool { documentManager.isSaving || documentManager.isConverting }
    private var hasScene: Bool { documentManager.scene != nil }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                errorBanner
                convertBanner
                mainContent
                metadataPanel
            }
            .navigationTitle(documentManager.fileMetadata?.name ?? "SKEdit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading)  { leadingToolbar }
                ToolbarItemGroup(placement: .topBarTrailing) { trailingToolbar }
            }
            .background {
                ZStack {
                    // Open .scn picker
                    DocumentPickerView(
                        isPresented: $isFilePickerPresented,
                        allowedContentTypes: allowedTypes,
                        onPick: { url in
                            selectedURL = url
                            BookmarkManager.saveBookmark(for: url)
                            Task { await loadFile(from: url) }
                        }
                    )
                    
                    // "Save to Files" export picker
                    ExportPickerView(exportURL: $usdzTempURL) { savedURL in
                        if let savedURL = savedURL {
                            let folder = savedURL.deletingLastPathComponent().lastPathComponent
                            withAnimation {
                                convertSuccessBanner =
                                "✓ '\(savedURL.lastPathComponent)' saved to '\(folder)'"
                            }
                            // ← NEW: auto-preview the saved file immediately after export
                            usdzPreviewURL = savedURL
                        }
                    }
                    
                    // ← NEW: In-app USDZ preview (object viewer — no AR room backdrop)
                    QuickLookPreviewView(previewURL: $usdzPreviewURL)
                }
            }
            .onAppear {
                if let restoredURL = BookmarkManager.restoreURL() {
                    selectedURL = restoredURL
                    Task { await loadFile(from: restoredURL) }
                }
            }
        }
    }
    
    // MARK: - Toolbar: Leading
    @ViewBuilder
    private var leadingToolbar: some View {
        Button {
            isFilePickerPresented = true
        } label: {
            Label("Open", systemImage: "folder")
        }
        
        if selectedURL != nil {
            Button {
                showMetadata.toggle()
            } label: {
                Label("Info", systemImage: "info.circle")
            }
        }
    }
    
    // MARK: - Toolbar: Trailing
    @ViewBuilder
    private var trailingToolbar: some View {
        if isBusy {
            ProgressView()
                .progressViewStyle(.circular)
        }
        
        if let url = selectedURL, !isBusy, hasScene {
            Button {
                Task { await saveFile(to: url) }
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            
            Button {
                Task { await convertToUSDZ(sourceName: url.lastPathComponent) }
            } label: {
                Label("Convert", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        
        // ← NEW: Preview button — only visible when a converted USDZ temp file exists
        if usdzTempURL != nil && !isBusy {
            Button {
                usdzPreviewURL = usdzTempURL
            } label: {
                Label("Preview", systemImage: "eye")
            }
        }
        
        if selectedURL != nil {
            Button(role: .destructive) {
                documentManager.clear()
                selectedURL          = nil
                showMetadata         = false
                convertSuccessBanner = nil
                usdzTempURL          = nil
                usdzPreviewURL       = nil   // ← NEW
            } label: {
                Label("Close", systemImage: "xmark.circle")
            }
        }
    }
    
    // MARK: - Body Subviews
    
    @ViewBuilder
    private var errorBanner: some View {
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
    }
    
    @ViewBuilder
    private var convertBanner: some View {
        if let msg = convertSuccessBanner {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Spacer()
                Button {
                    convertSuccessBanner = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.12))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            if documentManager.isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let scene = documentManager.scene {
                SceneKitView(scene: scene, cameraNode: $cameraNode)
                
            } else {
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
    }
    
    @ViewBuilder
    private var metadataPanel: some View {
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
    
    private func convertToUSDZ(sourceName: String) async {
        do {
            usdzTempURL = try await documentManager.convertToUSDZ(sourceName: sourceName)
        } catch {
            documentManager.errorMessage = "Convert failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
