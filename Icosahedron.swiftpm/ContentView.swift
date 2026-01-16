//  Icosahedron  01/16/2026-1
//  https://github.com/iypc-team/Playgrounds/tree/main/Icosahedron.swiftpm
// 

import SwiftUI

struct ContentView: View {
    let gvc = GameViewController()
    
    var body: some View {
        VStack {
            Text("gvc: \(gvc)")
            Text("gvc.debugDescription: \(gvc.debugDescription)")
            Text("children.count: \(gvc.classForCoder )")
            Text("shouldAutorotate: \(gvc.shouldAutorotate)")
            Text("prefersStatusBarHidden: \(gvc.prefersStatusBarHidden)")
            //            Text("gvc: \(gvc)")
            //            Text("gvc: \(gvc)")
            //            Text("gvc: \(gvc)")
        }
        .multilineTextAlignment(.leading)
        .font(.system(size: 18, weight: .regular, design: .default))
        .padding(10)
    }
}
