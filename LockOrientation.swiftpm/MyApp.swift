//  MyApp.swift
//  

import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var orientationManager = OrientationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(orientationManager)
        }
    }
}
