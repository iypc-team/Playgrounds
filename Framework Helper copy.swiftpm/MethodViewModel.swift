// MethodViewModel.swift
//  

import SwiftUI

@MainActor
class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let framework: Framework
    
    init(framework: Framework) {
        self.framework = framework
    }
    
    func fetchMethods() async {
//        isLoading = true
//        errorMessage = nil
//        defer { isLoading = false }
        
        let currentLibrary = framework.name
        print("currentLibrary: \(currentLibrary )")
        
    }
}

