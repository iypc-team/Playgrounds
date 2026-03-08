//  DF2Enemy_MVVM 03/08/2026-1
//  ContentView.swift
//  
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/DF2Enemy_MVVM.swiftpm
//  

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            ScenekitView(viewModel: viewModel)
                .onAppear {
                    viewModel.startAnimation()
                    print(viewModel.enemyShip.orientation)
                    print("enemyShip.position: \( viewModel.enemyShip.position)")
                }
                .onDisappear {
                    viewModel.stopAnimation()
                    // value of type 'SceneViewModel' has no dynamic member 'stopAnimation' using key path from root type 'SceneViewModel'
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
