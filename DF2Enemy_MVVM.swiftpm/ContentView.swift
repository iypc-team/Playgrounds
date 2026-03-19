//  DF2Enemy_MVVM 03/19/2026-2
//  ContentView.swift
//  Project:  DF2Enemy_MVVM.swiftpm
//  
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2Enemy_MVVM.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    @State private var combinedScene: SCNScene?
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            if let scene = combinedScene {
                ScenekitView(scene: scene, viewModel: viewModel)
            } else if let error = errorMessage {
                Text("Error loading scene: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("Loading scene...")
                    .foregroundColor(.white)
            }
            VStack {
                Spacer()
                HStack {
                    Button("Start Animate") {
                        viewModel.startAnimation()
                    }
                    
                    Button("Stop Animate") {
                        viewModel.stopAnimation()
                    }
                }
            }
            .font(.system(size: 20, weight: .semibold, design: .default))
            .foregroundColor(.white)
            .background(Color.clear)
            .padding(15)
        }
        .onAppear {
            setupScenes()
        }
        .onDisappear {
            viewModel.stopAnimation()
        }
    }
    
    private func setupScenes() {
        do {
            let universe = try viewModel.setupUniverse()
            let enemy = try viewModel.setupEnemyScene()
            for node in enemy.rootNode.childNodes {
                universe.rootNode.addChildNode(node)
            }
            combinedScene = universe
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
