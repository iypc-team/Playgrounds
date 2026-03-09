//  DF2Enemy_MVVM 03/09/2026-2
//  ContentView.swift
//  Project:  DF2Enemy_MVVM.swiftpm
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2Enemy_MVVM.swiftpm
//  

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    @State private var combinedScene: SCNScene?
    
    var body: some View {
        ZStack {
            if let scene = combinedScene {
                ScenekitView(scene: scene, viewModel: viewModel)
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
            let universe = viewModel.setupUniverse()
            let enemy = viewModel.setupEnemyScene()
            for node in enemy.rootNode.childNodes {
                universe.rootNode.addChildNode(node)
            }
            combinedScene = universe
            //            viewModel.startAnimation()
            //            print(viewModel.enemyShip.orientation)
            //            print("enemyShip.position: \( viewModel.enemyShip.position)")
        }
        .onDisappear {
            viewModel.stopAnimation()
            //  Value of type 'SceneViewModel' has no dynamic member 'stopAnimation' using key path from root type 'SceneViewModel'
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
