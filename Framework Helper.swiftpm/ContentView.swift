// Framework Helper  01/10/2026-1
// 
// https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
// 

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FrameworksViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.frameworks) { framework in
                Text(framework.name)
            }
            .navigationTitle("Frameworks")
            .onAppear {
                viewModel.fetchFrameworks()
            }
        }
    }
}
