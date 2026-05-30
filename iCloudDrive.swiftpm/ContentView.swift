//  iCloudDrive 05/30/2026-1
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ContentView: View {
    @StateObject private var vm = FilePickerViewModel()
    @State private var showingPicker = false
    @State private var clipboardToast = false
    // ✅ FIX 3: cancellable Task token for toast dismissal
    @State private var toastTask: Task<Void, Never>?
    
#if DEBUG
    // ✅ BONUS: lastEvent scoped to DEBUG only
    @State private var lastEvent = "Idle"
#endif
    
    var body: some View {
        // ✅ FIX 1: NavigationView → NavigationStack
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Pick files from iCloud Drive") {
#if DEBUG
                        lastEvent = "Picker presented"
#endif
                        showingPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    
#if DEBUG
                    Button("Mock add") {
                        vm.pickedURLs = [URL(fileURLWithPath: "/tmp/example.txt")]
                        vm.previewText = "Mock preview text"
                        lastEvent = "Mock added"
                    }
                    .buttonStyle(.bordered)
#endif
                }
                .padding(.horizontal)
                
#if DEBUG
                Text("Debug: \(lastEvent) • picked: \(vm.pickedURLs.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
#endif
                
                List {
                    Section(header: Text("Picked files")) {
                        if vm.pickedURLs.isEmpty {
                            Text("No files selected").foregroundColor(.secondary)
                        } else {
                            ForEach(vm.pickedURLs, id: \.self) { url in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(url.lastPathComponent).font(.headline)
                                    // ✅ FIX 2: url.path → url.path(percentEncoded: false)
                                    Text(url.path(percentEncoded: false))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .contextMenu {
                                    Button {
                                        // ✅ FIX 2: url.path → url.path(percentEncoded: false)
                                        copyToClipboard(url.path(percentEncoded: false))
                                    } label: {
                                        Label("Copy File Path", systemImage: "doc.on.clipboard")
                                    }
                                    Button {
                                        copyToClipboard(url.lastPathComponent)
                                    } label: {
                                        Label("Copy File Name", systemImage: "character.cursor.ibeam")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(
                        header: HStack {
                            // ✅ BONUS: clarifies only first file is previewed
                            Text("Preview (first file)")
                            Spacer()
                            Button {
                                copyToClipboard(vm.previewText)
                            } label: {
                                Label("Copy", systemImage: "doc.on.clipboard")
                                    .font(.caption)
                            }
                            .disabled(vm.previewText.isEmpty || vm.isLoading)
                            
                            Button {
                                if let pasted = UIPasteboard.general.string {
                                    vm.previewText = pasted
#if DEBUG
                                    lastEvent = "Pasted from clipboard"
#endif
                                }
                            } label: {
                                Label("Paste", systemImage: "clipboard")
                                    .font(.caption)
                            }
                            .disabled(UIPasteboard.general.string == nil)
                        }
                    ) {
                        if vm.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Loading preview...")
                                Spacer()
                            }
                            .frame(minHeight: 120)
                        } else {
                            ScrollView {
                                Text(vm.previewText.isEmpty ? "No preview available" : vm.previewText)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .contextMenu {
                                        Button {
                                            copyToClipboard(vm.previewText)
                                        } label: {
                                            Label("Copy Preview Text", systemImage: "doc.on.clipboard")
                                        }
                                    }
                            }
                            .frame(minHeight: 120)
                        }
                    }
                    
                    if let error = vm.errorMessage {
                        Section(header: Text("Error")) {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .contextMenu {
                                    Button {
                                        copyToClipboard(error)
                                    } label: {
                                        Label("Copy Error", systemImage: "doc.on.clipboard")
                                    }
                                }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .overlay(alignment: .bottom) {
                    if clipboardToast {
                        Text("Copied to clipboard")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                        // ✅ BONUS: .cornerRadius → .clipShape
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(radius: 4)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: clipboardToast)
            }
            .navigationTitle("iCloud Drive Picker")
            // ✅ REVERTED: back to .fileImporter — the correct API for Swift Playgrounds
            .fileImporter(
                isPresented: $showingPicker,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
#if DEBUG
                    lastEvent = "Importer success: \(urls.count) url(s)"
#endif
                    vm.handle(result: .success(urls))
                case .failure(let error):
#if DEBUG
                    lastEvent = "Importer failure: \(error.localizedDescription)"
#endif
                    vm.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Clipboard Helper
    
    private func copyToClipboard(_ text: String) {
        guard !text.isEmpty else { return }
        UIPasteboard.general.string = text
#if DEBUG
        lastEvent = "Copied to clipboard"
#endif
        showToast()
    }
    
    // ✅ FIX 3: cancellable Task — rapid copies always show a full 2-second toast
    private func showToast() {
        toastTask?.cancel()
        clipboardToast = true
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            clipboardToast = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .preferredColorScheme(.dark)
    }
}
