//  ContentViewModel.swift
//
//  Updated: adds re-entrancy protection and richer error handling.

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    @Published private(set) var isLoading: Bool = false
    
    /// Human-facing message suitable for display in the UI.
    @Published var errorMessage: String?
    
    /// The underlying error for diagnostics / tests.
    @Published private(set) var lastError: Error?
    
    private let repository: FrameworksRepository
    private var currentLoadTask: Task<Void, Never>?
    
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        self.repository = repository
    }
    
    /// Loads frameworks. If a load is already in progress this returns immediately.
    ///
    /// Uses an internal Task to support cancellation and to ensure only one concurrent
    /// load runs at a time.
    func load() async {
        // Prevent re-entrancy: don't start a second load while one is active.
        if currentLoadTask != nil {
            return
        }
        
        // Start a Task to perform the work. Store it so callers (or tests) can cancel if needed.
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
                self.lastError = nil
            }
            
            do {
                let items = try await self.repository.fetchFrameworks()
                // If the task was cancelled while awaiting, bail out without mutating state.
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.frameworks = items
                }
            } catch {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.frameworks = []
                    self.lastError = error
                    // Prefer LocalizedError.description when available
                    if let localized = (error as? LocalizedError)?.errorDescription {
                        self.errorMessage = localized
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            
            // Clear stored task reference (on completion)
            self.currentLoadTask = nil
        }
        
        currentLoadTask = task
        
        // Await task completion so callers awaiting load() don't return until the work finishes.
        await task.value
    }
    
    /// Cancels an in-flight load (if any). Leaves the view model in a consistent, non-loading state.
    func cancelLoad() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        
        Task { @MainActor in
            self.isLoading = false
        }
    }
}
