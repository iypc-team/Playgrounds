//  iCloudDrive 02/22/2026-6
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm

//
//  ContentView.swift
//  iCloudDrive Playground - MVVM
//
//  Updated: 2026-02-23
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var vm = FilePickerViewModel()
    @State private var showingPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Pick files from iCloud Drive") {
                    showingPicker = true
                }
                .padding()
                
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
            vm.handle(result: result)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
