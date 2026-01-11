// Framework Helper  01/11/2026-5
// 
//  print https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
//  

import SwiftUI

struct ContentView: View {
    private let frameworks: [Framework] = FrameworksConstants.knownFrameworks
        .map { Framework(name: $0) }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    
    var body: some View {
        NavigationView {
            List(frameworks) { framework in
                NavigationLink(destination: MethodListView(viewModel: MethodViewModel(framework: framework))) {
                    Text(framework.name)
                }
            }
            .navigationTitle("Libraries")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
