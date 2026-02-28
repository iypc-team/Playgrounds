//  LibraryViewModel.swift
//  

import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    // UI state
    @Published var frameworks: [Framework] = []
    @Published var searchText: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Underlying data source
    private let repository: FrameworksRepository
    
    // Task guard to avoid concurrent loads
    private var currentLoadTask: Task<Void, Never>?
    
    // Init without side effects; let the view call load() in .task or callers pass autoLoad: true if desired.
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        self.repository = repository
    }
    
    var filteredFrameworks: [Framework] {
        if searchText.isEmpty {
            return frameworks
        } else {
            return frameworks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Load frameworks using the repository. If a load is already active, returns immediately.
    func load() async {
        // Prevent re-entrancy
        if currentLoadTask != nil { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                let items = try await self.repository.fetchFrameworks()
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.frameworks = items
                }
            } catch {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.frameworks = []
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            
            // clear task reference
            self.currentLoadTask = nil
        }
        
        currentLoadTask = task
        await task.value
    }
    
    /// Cancel an in-flight load.
    func cancelLoad() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        
        Task { @MainActor in
            self.isLoading = false
        }
    }
}
