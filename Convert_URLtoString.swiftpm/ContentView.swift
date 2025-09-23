import SwiftUI
import SceneKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    print(documentsDirectory)
    return documentsDirectory
}


//class GetDocuments {
//    let fm = FileManager.default
//
//    func searchDocumentsDirectory() {
//        do {
//            let items = try fm.contentsOfDirectory(atPath: path.absoluteString)
//            print(items)
//            for item in items {
//                print("Found \(item)")
//            }
//        } catch {
//            print("failed to read directory – bad permissions, perhaps?")
//        }
//    }
//}

struct ContentView: View {
//    let gd = GetDocuments()
    // var documentsDirectory = getDocumentsDirectory()
    var body: some View {
        
        VStack {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let pathString = path.absoluteString
            let url = path.appendingPathComponent("enemy1.scn")
            let urlString = url.absoluteString
            Image(systemName: "gamecontroller")
                .imageScale(.large)
                .scaledToFit()
                .foregroundColor(.blue)
                .padding()
            
            Text("path:  \(pathString)")
                .foregroundColor(.blue)
                .padding(.vertical)
            Text(urlString)
                .foregroundColor(.green)
        }
    }
}



struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
