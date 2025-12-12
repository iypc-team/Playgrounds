// AI SpaceshipDemoApp 12/11/2025-3
/*
 https://github.com/iypc-team/Playgrounds/tree/main/AI%20SpaceshipDemoApp.swiftpm
 */
// SwiftUI + RealityKit, loadModel(Airplane.usdz), no ArView, iOS 16, MVVM paradigm

import SwiftUI

struct printInfo {
    init() { print("ContentView()") }
}

struct ContentView: View {
    @StateObject private var model = AirplaneModel()
    let pi = printInfo() 
    
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
                                    let dragAngle = Angle(degrees: Double(value.translation.height) * 1.0) // 0.01 default
                                    
                                    model.rotation = dragAngle
                                }
                                .onEnded { _ in
                                    //                                    print("dragAngle: \(dragAngle)")
                                }
                            )
                    )
                    .overlay(
                        HStack(spacing: 20) {  // Changed to HStack for horizontal stacking
                            Spacer()
                            Button("Start Rotation") {
                                print("\nRotate pressed")
                                Task {
                                    model.rotateModel()
                                    // no 'async'operations occur within 'await' expression
                                }
                            }
                            .padding(15)
                            .font(.system(size: 18, weight: .heavy, design: .default))
                            .foregroundColor(.green)
                            .background(Color.black)
                            
                            Spacer()
                            
                            Button("Cancel Rotation") {
                                print("\nCancel Rotation pressed")
                                model.cancelRotation()
                                model.resetRotation()
                            }
                            .padding(15)
                            .font(.system(size: 18, weight: .heavy, design: .default))  // Slightly smaller for hierarchy
                            .foregroundColor(.red)
                            .background(Color.black)
                            
                            Spacer()
                        }
                        , alignment: .bottom
                    )
            } else {
                Text("Loading model...")
                    .onAppear { model.loadModel() }
            }
        }
    }
}
