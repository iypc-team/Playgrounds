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
        .onAppear() {
            print(framework.name.description)
            print(framework.name.count)
            print(framework.name.components(separatedBy: ","))
            print("publisher: \( framework.name.publisher)")
            print(framework.name.startIndex)
        }
    }
}

struct MethodListView_Previews: PreviewProvider {
    static var previews: some View {
        MethodListView(framework: Framework(name: "SwiftUI"))
    }
}
