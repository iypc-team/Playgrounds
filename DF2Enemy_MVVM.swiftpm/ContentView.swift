// DF2Enemy_MVVM 01/08/2026-3
/*   
 https://github.com/iypc-team/Playgrounds/tree/main/DF2Enemy_MVVM.swiftpm  
*/
//   

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SceneViewModel()
    
    var body: some View {
        ScenekitView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
