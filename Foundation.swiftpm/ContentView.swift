import SwiftUI
import Foundation

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

extension View {
    func leftAligned() -> some View {
        return self.modifier(LeftAligned())
    }
}

struct fileManager {
    static let fm = FileManager.default
    
    static let url = fm.urls(for: .documentDirectory, in: .localDomainMask).first
    
    static let currentDirectory = fm.currentDirectoryPath
    static let resourcePath = Bundle.main.resourcePath!
    
    static let bundleId = Bundle.main.bundleIdentifier
    static let documentsDirectory = getDocumentsDirectory()
    static let cacheDirectory = getCacheDirectory()
    static let applicationSupportDirectory = getApplicationSupportDirectory()
    static let documentsDirectoryContents = fm.contents(atPath: documentsDirectory.absoluteString)
    
    static func getDocumentsDirectory(printResults: Bool = false) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if printResults { print("documentDirectory:\n", paths[0])}
        return paths[0]
    }
    
    static func getCacheDirectory(printResults: Bool = false) -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        if printResults { print("cacheDirectory:\n", paths[0])}
        return paths[0]
    }
    
    static func getApplicationSupportDirectory(printResults: Bool = false) -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if printResults == true {
            print("applicationSupportDirectory:\n", paths[0])
        }
        return paths[0]
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("documentsDirectory:\n\(fileManager.documentsDirectory)\n")
                Text("cachesDirectory:\n\(fileManager.cacheDirectory)\n")
                Text("ApplicationSupportDirectory:\n\(fileManager.applicationSupportDirectory)\n")
                
                Text("resourcePath:\n\(fileManager.resourcePath)\n")
                Text("bundleId:\n\(String(describing: fileManager.bundleId!))\n")
                Text("documentsDirectoryContents:\n\(String(describing: fileManager.documentsDirectory))\n")
                Text("url:\n\(String(describing: fileManager.url))\n")
            }
        }
        //        .foregroundColor(.blue)
        .bold()
        .padding(30)
    }
}



struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

