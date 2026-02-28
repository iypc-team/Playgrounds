//  ContentViewModel.swift
//  

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: FrameworksRepository
    
    init(repository: FrameworksRepository = StaticFrameworksRepository()) {
        self.repository = repository
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let items = try await repository.fetchFrameworks()
            frameworks = items
        } catch {
            frameworks = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
