// Framework Helper  01/11/2026-9
// 
//  https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
/*  
A NavigationLink is presenting a value of type “Framework” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated.
 
 Note: Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
 */


import SwiftUI

struct ContentView: View {
    private let frameworks: [Framework] = FrameworksConstants.sortedFrameworks()
    
    var body: some View {
        NavigationStack {
            List(frameworks) { framework in
                //  initializer 'init(value:label:)' requires that 'Framework' conform to 'Hashable'
                NavigationLink(value: framework) {
                    Text(framework.name)
                }
            }
            .navigationTitle("Libraries")
        }
        .navigationDestination(for: Framework.self) { framework in 
            Text("Details for \(framework.name)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
