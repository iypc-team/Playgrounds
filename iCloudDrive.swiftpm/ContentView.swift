//  iCloudDrive 05/29/2026-2
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ContentView: View {
    @StateObject private var vm = FilePickerViewModel()
    @State private var showingPicker = false
    @State private var lastEvent = "Idle"
    @State private var clipboardToast = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Pick files from iCloud Drive") {
                        lastEvent = "Picker presented"
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
                                    Text(url.path).font(.caption).foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                // Long-press to copy file path
                                .contextMenu {
                                    Button {
                                        copyToClipboard(url.path)
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
                            Text("Preview")
                            Spacer()
                            // Copy preview text button — disabled when there is nothing to copy
                            Button {
                                copyToClipboard(vm.previewText)
                            } label: {
                                Label("Copy", systemImage: "doc.on.clipboard")
                                    .font(.caption)
                            }
                            .disabled(vm.previewText.isEmpty || vm.isLoading)
                            
                            // Paste from clipboard into preview
                            Button {
                                if let pasted = UIPasteboard.general.string {
                                    vm.previewText = pasted
                                    lastEvent = "Pasted from clipboard"
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
                                // Long-press on preview text to copy
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
                            // Long-press to copy error message
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
                // Toast overlay for clipboard confirmation
                .overlay(alignment: .bottom) {
                    if clipboardToast {
                        Text("Copied to clipboard")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                            .shadow(radius: 4)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: clipboardToast)
            }
            .navigationTitle("iCloud Drive Picker")
            .fileImporter(
                isPresented: $showingPicker,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    lastEvent = "Importer success: \(urls.count) url(s)"
                    vm.handle(result: .success(urls))
                case .failure(let error):
                    lastEvent = "Importer failure: \(error.localizedDescription)"
                    vm.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Clipboard Helper
    
    private func copyToClipboard(_ text: String) {
        guard !text.isEmpty else { return }
        UIPasteboard.general.string = text
        lastEvent = "Copied to clipboard"
        showToast()
    }
    
    private func showToast() {
        clipboardToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            clipboardToast = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
