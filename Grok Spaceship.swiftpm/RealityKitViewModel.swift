// 
// RealityKitViewModel
//

import SwiftUI

class RealityKitViewModel: ObservableObject {
    let rkv = RealityKitView(modelName: "Spaceship.usdz")
    @Published var rotation: Float = 0.0
    
    func rotate() {
        print("func rotate()")
        rkv.rotateModel()
    }
}
