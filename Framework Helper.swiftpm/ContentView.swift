// Framework Helper  01/11/2026-2
// 
// https://github.com/iypc-team/Playgrounds/tree/main/Framework%20Helper.swiftpm
//  

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.filteredFrameworks) { framework in
                NavigationLink(destination: MethodListView(viewModel: MethodViewModel(framework: framework))) {
                    Text(framework.name)
                }
            }
            .navigationTitle("Libraries")
            .searchable(text: $viewModel.searchText, prompt: "Search frameworks")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
