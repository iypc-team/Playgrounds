//  Icosahedron  01/16/2026-4
//  Copyright © 2018 IYPC Software. All rights reserved.
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron.swiftpm
// 

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        GameViewControllerRepresentable()
    }
}

struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // No updates needed for this static view
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
