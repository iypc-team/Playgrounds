// Framework Helper  11/05/2026-1
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
