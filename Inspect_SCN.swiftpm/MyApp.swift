//  MyApp.swift
//  

import SwiftUI

@main
struct MyApp: App {
    @StateObject private var viewModel = SceneViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
