//  FrameworksRepository.swift
//  

import Foundation 

protocol FrameworksRepository {
    /// Fetch the frameworks. Async so implementations can be local or remote.
    func fetchFrameworks() async throws -> [Framework]
}

/// Simple repository backed by FrameworksConstants (updated to load from JSON).
struct StaticFrameworksRepository: FrameworksRepository {
    func fetchFrameworks() async throws -> [Framework] {
        try await FrameworksConstants.sortedFrameworks()
    }
}

/// A small mock repository driven by a Result value. Useful for previews.
struct MockFrameworksRepository: FrameworksRepository {
    let result: Result<[Framework], Error>
    
    init(result: Result<[Framework], Error>) {
        self.result = result
    }
    
    func fetchFrameworks() async throws -> [Framework] {
        switch result {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
}
