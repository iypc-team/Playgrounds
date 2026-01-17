//  Icosahedron  01/17/2026-1
//  Copyright © 2018 IYPC Software. All rights reserved.
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron.swiftpm
// 

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black // Set the background color to black
                .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
            
            GameViewControllerRepresentable()
                .onAppear {
                    print("GameViewControllerRepresentable loaded.")
                }
                .onDisappear {
                    print("GameViewControllerRepresentable unloaded.")
                }
        }
        .overlay(Text("Loading...") // Add a fallback text in case it takes time to load
            .foregroundColor(.white))
    }
}

struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        // Ensure GameViewController is loading correctly; fallback debug
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        print("GameViewController updated.")
        // No updates needed for this static view
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
