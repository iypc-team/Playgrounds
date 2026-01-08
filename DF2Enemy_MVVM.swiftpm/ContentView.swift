// DF2Enemy_MVVM 01/08/2026-4
/*   
 https://github.com/iypc-team/Playgrounds/tree/main/DF2Enemy_MVVM.swiftpm  
 */

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        ZStack {
            ScenekitView(viewModel: viewModel)
                .onAppear {
                    print("enemyShip.position: \( viewModel.enemyShip.position)")
                }
                .onDisappear {
                    viewModel.stopAnimation()
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
            .font(.title3)
            .foregroundColor(.white)
            .background(Color.clear)
            .padding(20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
