// 
// 

import SwiftUI

struct MethodListView: View {
    let framework: Framework
    
    var body: some View {
        VStack {
            Text("Methods for \(framework.name)")
                .font(.largeTitle)
                .padding()
            // Add your method listing logic here, e.g., a List of methods
            Spacer()
        }
        .navigationTitle(framework.name)
    }
}

struct MethodListView_Previews: PreviewProvider {
    static var previews: some View {
        MethodListView(framework: Framework(name: "SwiftUI"))
    }
}
