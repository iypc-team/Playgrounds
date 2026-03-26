//  MyApp.swift
//  

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .handlesExternalEvents(preferring: Set(["SceneDelegate"]), allowing: Set(["SceneDelegate"]))
    }
}
