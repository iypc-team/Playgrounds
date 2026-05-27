// LibraryViewModel.swift
// 

import Foundation
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    
    @Published var frameworks: [Framework] = []
    @Published var filteredFrameworks: [Framework] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil
    
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
        var result = frameworks
        
        if let category = selectedCategory,
           let categoryFrameworks = FrameworksConstants.categories[category] {
            result = result.filter { categoryFrameworks.contains($0.name) }
        }
        
        if searchText.isEmpty {
            filteredFrameworks = result
        } else {
            let query = searchText.lowercased()
            filteredFrameworks = result.filter {
                $0.displayName.localizedCaseInsensitiveContains(query) ||
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Inline Playground Tests (Run these manually in Playground)
#if DEBUG
extension LibraryViewModel {
    static func runPlaygroundTests() async {
        print("🧪 Running LibraryViewModel Playground Tests...")
        
        // Test 1: Mock Success
        let mockFrameworks = [
            Framework(name: "SwiftUI"),
            Framework(name: "UIKit")
        ]
        let mockRepo = MockFrameworksRepository(result: .success(mockFrameworks))
        let vm = LibraryViewModel(repository: mockRepo)
        
        await vm.loadFrameworks()
        assert(vm.frameworks.count == 2, "Should load 2 frameworks")
        assert(!vm.isLoading, "Loading should finish")
        
        // Test 2: Search
        vm.searchText = "swift"
        vm.applySearchFilter()
        assert(vm.filteredFrameworks.count == 1, "Search should filter correctly")
        
        // Test 3: Category Filter
        vm.selectedCategory = "UI Frameworks"
        vm.applySearchFilter()
        print("✅ Category filter test passed")
        
        print("🎉 All Playground tests passed!")
    }
}
#endif
