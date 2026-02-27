//  Framework Helper  02/27/2026-1
//  ContentView.swift
//  https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
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
                FrameworkDetailView(framework: framework)
            }
        }
    }
}

struct FrameworkDetailView: View {
    let framework: Framework
    
    var body: some View {
        VStack {
            Text(framework.name)
                .font(.largeTitle)
            // more detail UI here
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        ContentView()
            .preferredColorScheme(.dark)
    }
}
