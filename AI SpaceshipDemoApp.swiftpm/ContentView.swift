// AI SpaceshipDemoApp 12/10/2025-1
//  https://github.com/iypc-team/Playgrounds/tree/main/AI%20SpaceshipDemoApp.swiftpm
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI

struct printInfo {
    init() {
        print("ContentView()")
    }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    let pi = printInfo() 
    
    func printModelScale() -> Float {
        let scale = model.scale
        print("Model scale: \(scale)")
        return scale
    }
    
    var body: some View {
        VStack {
            if let _ = model.entity {
                RealityKitView(model: model)  // Pass model, not entity
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                    .frame(maxWidth: 200, maxHeight: 200)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                model.scale = Float(value)
                            }
                            .onEnded { value in
                                print("Magnification value: \(value)")  // Add this line
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { value in
                                    // Calculate rotation based on horizontal drag (adjust 0.01 for sensitivity)
                                    let dragAngle = Angle(degrees: Double(value.translation.width) * 0.01)
                                    model.rotation = dragAngle
                                }
                                .onEnded { _ in
                                    //                                    print("dragAngle: \(dragAngle)")
                                }
                            )
                    )
                    .overlay(
                        Button("Rotate") {
                            print("\nRotate pressed")
                            Task {
                                model.rotateModel()
                                // no 'async'operations occur within 'await' expression
                            }
                        }
                            .padding(10)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .background(Color.black)
                        , alignment: .bottom
                    )
            } else {
                Text("Loading model...")
                    .onAppear { model.loadModel() }
            }
        }
    }
}
