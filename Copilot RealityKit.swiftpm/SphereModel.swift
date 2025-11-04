// 
// 

import UIKit

// MARK: - Model
struct SphereModel {
    var sphereColor: UIColor
    var childUSDZFileName: String = "Airplane" // name of the .usdz file in the bundle
    var childPosition: SIMD3<Float> = [0, 0.5, 0] // Position offset relative to the sphere
}
