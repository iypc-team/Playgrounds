//
//  MyApp.swift
//  Icosahedron-2
//
//  Created by Code GPT 🧠 on 01/21/2026.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            PolyhedronViewer() // ✅ Use the interactive viewer
                .preferredColorScheme(.dark)
        }
    }
}
