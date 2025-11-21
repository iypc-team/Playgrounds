// 
// 

import SwiftUI
import RealityKit

struct AirplaneRealityView: View {
    @StateObject var viewModel = AirplaneViewModel()
    
    var body: some View {
        RealityView { content in
            content.camera = .virtual(fov: .degrees(60), distance: 1.5)
            
            // Load model if needed
            if viewModel.airplaneEntity == nil {
                viewModel.loadModel()
            }
            
            if let airplane = viewModel.airplaneEntity {
                // Attach simple lighting
                let light = PointLight()
                light.light.intensity = 600
                light.position = [0, 1, 2]
                content.add(light)
                
                // Apply any transforms from gestures
                airplane.transform = viewModel.currentTransform
                content.add(airplane)
            }
        }
        // Example gestures
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    var transform = viewModel.currentTransform
                    transform.translation.x += Float(gesture.translation.width) * 0.001
                    transform.translation.y -= Float(gesture.translation.height) * 0.001
                    viewModel.currentTransform = transform
                }
        )
    }
}
