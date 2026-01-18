//  Icosahedron-2  01/18/2026-5
//  Copyright © 2018 IYPC Software. All rights reserved.
//
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron-2.swiftpm
//
//  

import SwiftUI
import SceneKit
import UIKit

struct SceneKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // No updates needed
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
            .preferredColorScheme(.dark)
    }
}
