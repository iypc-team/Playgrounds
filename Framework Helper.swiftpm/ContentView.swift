// Framework Helper  01/10/2026-2
// 
// https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
// 

import SwiftUI

//
// 

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FrameworksViewModel()
    @State private var searchText = ""
    
    var filteredFrameworks: [Framework] {
        if searchText.isEmpty {
            return viewModel.frameworks
        } else {
            return viewModel.frameworks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredFrameworks) { framework in
                Text(framework.name)
            }
            .navigationTitle("Frameworks")
            .searchable(text: $searchText, prompt: "Search frameworks")
            .onAppear {
                viewModel.fetchFrameworks()
            }
        }
    }
}

//struct ContentView: View {
//    @StateObject private var viewModel = FrameworksViewModel()
//    
//    var body: some View {
//        NavigationView {
//            List(viewModel.frameworks) { framework in
//                Text(framework.name)
//            }
//            .navigationTitle("Frameworks")
//            .onAppear {
//                viewModel.fetchFrameworks()
//            }
//        }
//    }
//}
