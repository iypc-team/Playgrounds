// DF2Enemy_MVVM 01/09/2026-2
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
//                    print(viewModel.enemyShip.orientation)
//                    print("enemyShip.position: \( viewModel.enemyShip.position)")
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
            .font(.system(size: 20, weight: .regular, design: .default))
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
