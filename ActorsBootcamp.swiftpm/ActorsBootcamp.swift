import SwiftUI

actor DataManager {
    static let instance = DataManager()
    private init() { }
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()!
    }
}

struct HomeView: View {
    let manager = DataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 10.0, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.yellow).opacity(1.0).ignoresSafeArea()
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .default))
        }
        .onReceive(timer, perform: { _ in
            Task {
                //                print("\nBrowseView")
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        })
    }
}

struct BrowseView: View {
    let manager = DataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.5, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.green).opacity(1.0).ignoresSafeArea()
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .default))
        }
        .onReceive(timer, perform: { _ in
            Task {
                //                print("\nBrowseView")
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        })
    }
}

struct ActorsBootcamp: View {
    var body: some View{
        TabView {
            HomeView()
                .tabItem  {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem { 
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}



struct ActorsBootcamp_Preview: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
        
    }
}


