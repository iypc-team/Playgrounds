//  Framework Helper copy  02/27/2026-1
//  
//   https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper%20copy.swiftpm
//

import SwiftUI

struct ContentView: View {
    private let frameworks: [Framework] = FrameworksConstants.sortedFrameworks()
    
    var body: some View {
        NavigationStack {
            List(frameworks) { framework in
                NavigationLink(value: framework) {
                    Text(framework.name)
                }
            }
            .navigationTitle("Libraries")
            // IMPORTANT: destination attached to the same NavigationStack
            .navigationDestination(for: Framework.self) { framework in
                MethodListView(framework: framework)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
