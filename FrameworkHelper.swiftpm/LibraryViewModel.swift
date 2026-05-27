// LibraryViewModel.swift

import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    
    @Published var frameworks: [Framework] = []
    @Published var filteredFrameworks: [Framework] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private var currentLoadTask: Task<Void, Never>?
    private let repository: FrameworksRepository
    
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        self.repository = repository
        self.filteredFrameworks = []
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
            // ✅ Now calls the injected repository — restores testability.
            let loaded = try await repository.fetchFrameworks()
            frameworks = loaded.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
            applySearchFilter()
        } catch {
            errorMessage = "Failed to load frameworks: \(error.localizedDescription)"
            frameworks = []
            filteredFrameworks = []
        }
        
        isLoading = false
    }
    
    func applySearchFilter() {
        if searchText.isEmpty {
            filteredFrameworks = frameworks
        } else {
            let query = searchText.lowercased()
            filteredFrameworks = frameworks.filter {
                $0.displayName.lowercased().contains(query) ||
                $0.name.lowercased().contains(query)
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
