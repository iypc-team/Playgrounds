// FrameworksRepository.swift
// 

import Foundation 

protocol FrameworksRepository {
    func fetchFrameworks() async throws -> [Framework]
}

struct StaticFrameworksRepository: FrameworksRepository {
    func fetchFrameworks() async throws -> [Framework] {
        // Now loads from JSON with categories support
        await Task.yield() // Simulate slight async
        return FrameworksConstants.loadFrameworks()
    }
}

struct MockFrameworksRepository: FrameworksRepository {
    let result: Result<[Framework], Error>
    
    init(result: Result<[Framework], Error> = .success([])) {
        self.result = result
    }
    
    func fetchFrameworks() async throws -> [Framework] {
        switch result {
        case .success(let items): return items
        case .failure(let error): throw error
        }
    }
}
