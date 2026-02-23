//  iCloudDrive 02/22/2026-9
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm
//  

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var vm = FilePickerViewModel()
    @State private var showingPicker = false
    @State private var lastEvent = "Idle"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Pick files from iCloud Drive") {
                        lastEvent = "Picker presented"
                        showingPicker = true
                    }
                    Button("Mock add") {
                        vm.pickedURLs = [URL(fileURLWithPath: "/tmp/example.txt")]
                        vm.previewText = "Preview text"
                        lastEvent = "Mock added"
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                Text("Debug: \(lastEvent) • picked: \(vm.pickedURLs.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
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
                            }
                        }
                    }
                    
                    Section(header: Text("Preview")) {
                        ScrollView {
                            Text(vm.previewText.isEmpty ? "No preview available" : vm.previewText)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                        .frame(minHeight: 120)
                    }
                    
                    if let error = vm.errorMessage {
                        Section {
                            Text("Error: \(error)")
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
                lastEvent = "Importer success: \(urls.count) url(s)"
                vm.handle(result: result)
            case .failure(let error):
                lastEvent = "Importer failure: \(error.localizedDescription)"
                vm.errorMessage = error.localizedDescription
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
