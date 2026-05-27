// ContentViewModel.swift

import Foundation
import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    
    @Published var frameworks: [Framework] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var currentLoadTask: Task<Void, Never>?
    private let repository: FrameworksRepository
    
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        self.repository = repository
    }
    
    func loadFrameworks() async {
        guard currentLoadTask == nil else { return }
        
        currentLoadTask = Task {
            await loadFrameworksInternal()
            currentLoadTask = nil
        }
    }
    
    private func loadFrameworksInternal() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Use the injected repository so the abstraction is actually exercised
            // (enables testing via MockFrameworksRepository).
            let loaded = try await repository.fetchFrameworks()
            frameworks = loaded.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
        } catch {
            errorMessage = "Failed to load frameworks: \(error.localizedDescription)"
            frameworks = []
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
