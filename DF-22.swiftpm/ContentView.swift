//  DF-22  03/12/2026-2
//  ContentView.swift
//  Project:  DF-22.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF-22.swiftpm
//  

import SwiftUI
import SceneKit
import CoreMotion  // Added for motion integration awareness

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            SceneKitUIView(scene: viewModel.scene)
            
            VStack {
                Spacer()
                HStack {
// Value of type 'SceneViewModel' has no dynamic member 'startMotion' using key path from root type 'SceneViewModel'
                    Button(action: { viewModel.startMotion() }) {
                        Text("Start Motion")
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(8)
                    }
                    Button(action: { viewModel.stopMotion() }) {
                        Text("Stop Motion")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
}

struct SceneKitUIView: UIViewRepresentable {
    var scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        // Configure the view
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.darkGray
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.isTemporalAntialiasingEnabled = true
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
