// Framework Helper  01/10/2026-8
// 
// https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
//  

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryListView()
    @State private var searchText = ""
    
    var filteredFrameworks: [Framework] {
        if searchText.isEmpty {
            return viewModel.frameworks
        } else {
            return viewModel.frameworks.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredFrameworks) { framework in
                NavigationLink(destination: MethodListView(framework: framework)) {
                    Text(framework.name)
                }
            }
            .navigationTitle("Libraries")
            .searchable(text: $searchText, prompt: "Search frameworks")
            .onAppear {
                viewModel.fetchFrameworks()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
