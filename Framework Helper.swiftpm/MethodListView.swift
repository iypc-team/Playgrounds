// 
// 

import SwiftUI

struct MethodListView: View {
    let framework: Framework
    //    var libraryName: String = ""
    
    var body: some View {
        VStack {
            
            Text("Classes for \(framework.name)")
                .font(.largeTitle)
                .padding()
            // Add your method listing logic here, e.g., a List of methods
            Spacer()
        }
        .navigationTitle(framework.name)
        .onAppear() {
            print("\(framework.name)")
            print("framework.name.count: \(framework.name.count)")
            print("framework.id: \(framework.id)")
            
            print()
        }
    }
}
