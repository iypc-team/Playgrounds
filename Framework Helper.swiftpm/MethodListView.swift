// 
// 

import SwiftUI

struct MethodListView: View {
    let framework: Framework
    var libraryName: String = "" 
    
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
            libraryName = framework.name
            print("libraryName: \(libraryName)")
            print(framework.name.description)
            print(framework.name.count)
            print(framework.name.components(separatedBy: ","))
            print("publisher: \( framework.name.publisher)")
            print(framework.name.startIndex)
        }
    }
    
    func listAllClasses() -> [String] {
        return ["AppDelegate", "EarthNode", "GameViewController", "ManagerClass", "MotionDataProvider", "MotionManager", "MotionViewModel", "MVVMBootcampViewModel", "SceneModel", "Starfield"]
    }
}

struct MethodListView_Previews: PreviewProvider {
    static var previews: some View {
        MethodListView(framework: Framework(name: "SwiftUI"))
    }
}
