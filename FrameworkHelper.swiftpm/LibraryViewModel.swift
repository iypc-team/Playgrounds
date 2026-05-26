// LibraryViewModel.swift

import Foundation
import SwiftUI

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
            frameworks = try await FrameworksConstants.sortedFrameworks()
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
            let lowercasedSearch = searchText.lowercased()
            filteredFrameworks = frameworks.filter { framework in
                framework.displayName.lowercased().contains(lowercasedSearch) ||
                framework.name.lowercased().contains(lowercasedSearch)
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
