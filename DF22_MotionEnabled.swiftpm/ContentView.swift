//  DF22_MotionEnabled 03/23/2026-2
//  ContentView.swift
//  Project:  DF22_MotionEnabled.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF22_MotionEnabled.swiftpm
//  

import SwiftUI
import SceneKit
import CoreMotion  // Added for motion integration awareness

struct ContentView: View {
    @StateObject private var viewModel = SceneViewModel()
    @State private var selectedShip = "fighter"
    
    var body: some View {
        ZStack {
            SceneKitUIView(combatScene: viewModel.combatScene)
            
            VStack {
                Picker("Ship", selection: $selectedShip) {
                    Text("fighter").tag("fighter")
                    Text("newFighter").tag("newFighter")
                    Text("fighterPBR").tag("fighterPBR")
                    Text("smooth_ship").tag("smooth_ship")
                    Text("airplane").tag("airplane")
                    Text("Y-Up-fighter.scn").tag("Y-Up-fighter.scn")
                }
                .pickerStyle(.menu)
                .onChange(of: selectedShip) { newValue in
                    viewModel.changeShip(to: newValue)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
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
            .font(.system(size: 20, weight: .semibold, design: .default))
        }
        .onTapGesture(count: 2) {
            viewModel.shieldsEnabled.toggle()
            print("shieldsEnabled: \(viewModel.shieldsEnabled)")
        }
        .onAppear {
            viewModel.changeShip(to: selectedShip)
        }
    }
}

struct SceneKitUIView: UIViewRepresentable {
    var combatScene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = combatScene
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = combatScene
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
