// DF2Enemy_MVVM initial commit 01/08/2026
/*
 
 */

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
