// iCloud Drive 05/28/2026-4
// ContentView.swift
// Repo: https://github.com/iypc-team/Playgrounds/tree/main/iCloud%20Drive.swiftpm

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @StateObject private var manager = iCloudDriveManager()
    
    @State private var isAuthenticated = false
    @State private var showingSignInSheet = false
    @State private var password: String = ""
    @State private var passwordError: String? = nil
    @State private var showingNewFileSheet = false
    @State private var newFileName: String = ""
    @State private var newFileContent: String = ""
    @State private var selectedFileURL: URL? = nil
    @State private var showingPreview = false
    
    // Set your password here
    private let correctPassword = "icloud123"
    
    var body: some View {
        NavigationStack {
            VStack {
                if !isAuthenticated {
                    // MARK: - Sign In View
                    Spacer()
                    VStack(spacing: 24) {
                        Image(systemName: "lock.icloud.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.blue)
                        
                        Text("iCloud Drive")
                            .font(.largeTitle.bold())
                        
                        Text("Authenticate to access your files.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Biometric Button
                        Button {
                            authenticateWithBiometrics()
                        } label: {
                            Label(biometricLabel(), systemImage: biometricIcon())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        
                        // Password Button
                        Button {
                            showingSignInSheet = true
                        } label: {
                            Label("Sign In with Password", systemImage: "key.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.gray.opacity(0.15))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                    
                } else if manager.iCloudFiles.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "icloud")
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
                if isAuthenticated {
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation { isAuthenticated = false }
                        } label: {
                            Label("Lock", systemImage: "lock.fill")
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                VStack {
                    if let error = manager.errorMessage {
                        HStack {
                            Text(error).foregroundStyle(.red)
                            Spacer()
                            Button("Dismiss") { manager.clearMessages() }
                        }
                        .padding()
                        .background(.red.opacity(0.1))
                    }
                    if let success = manager.successMessage {
                        HStack {
                            Text(success).foregroundStyle(.green)
                            Spacer()
                            Button("Dismiss") { manager.clearMessages() }
                        }
                        .padding()
                        .background(.green.opacity(0.1))
                    }
                }
            }
        }
        // MARK: - Password Sign In Sheet
        .sheet(isPresented: $showingSignInSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    Image(systemName: "lock.icloud.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.blue)
                        .padding(.top)
                    
                    Text("Enter Password")
                        .font(.title2.bold())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    if let error = passwordError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    
                    Button {
                        verifyPassword()
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding()
                .navigationTitle("iCloud Sign In")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            password = ""
                            passwordError = nil
                            showingSignInSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
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
            authenticateWithBiometrics()
        }
    }
    
    // MARK: - Biometrics
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Biometrics not available, fall through to password
            return
        }
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access iCloud Drive"
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    isAuthenticated = true
                    manager.listFiles()
                }
            }
        }
    }
    
    private func verifyPassword() {
        if password == correctPassword {
            passwordError = nil
            password = ""
            showingSignInSheet = false
            isAuthenticated = true
            manager.listFiles()
        } else {
            passwordError = "Incorrect password. Please try again."
            password = ""
        }
    }
    
    private func biometricLabel() -> String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Biometrics Unavailable"
        }
        return context.biometryType == .faceID ? "Sign In with Face ID" : "Sign In with Touch ID"
    }
    
    private func biometricIcon() -> String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "touchid"
        }
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }
    
    private func resetNewFileForm() {
        newFileName = ""
        newFileContent = ""
    }
}

// MARK: - File Preview
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
                    Button("Done") { }
                }
            }
            .onAppear { loadFileContent() }
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
