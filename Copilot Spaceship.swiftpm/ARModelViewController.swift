// 

import UIKit
import RealityKit

class ARModelViewController: UIViewController {
    var arView: ARView!
    var viewModel = ModelViewModel()
    var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: self.view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(arView)
        
        // Observe entity changes
        viewModel.loadModel()
        cancellable = viewModel.$entity.sink { [weak self] entity in
            guard let self = self, let entity = entity else { return }
            let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
            anchor.addChild(entity)
            self.arView.scene.anchors.append(anchor)
        }
    }
}

