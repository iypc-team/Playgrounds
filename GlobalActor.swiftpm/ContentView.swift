//  GlobalActor  09/05/2025-1
// sleep
import SwiftUI
@globalActor struct FirstGlobalActor {
    static var shared = DataManager()
}
actor DataManager {
    // DO NOT access DataManager directly!!
    // Access DataManager through FirstGlobalActor
    func getDataFromDatabase() -> [String] {
        return ["one", "two", "three", "four", "five", "shit"]
    }
}

class GlobalActorViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    let manager = FirstGlobalActor.shared
    
    @FirstGlobalActor func getData() async  {
        let data = await manager.getDataFromDatabase()
        self.dataArray = data
    }
}

struct GlobalActor: View {
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Image(systemName: "house.fill")
                    .imageScale(.large)
                    .foregroundColor(.cardinalRed)
                    .font(.system(size: 150, weight: .light, design: .default))
                Text("GlobalActor")
                    .font(.title)
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.title3)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}


struct GlobalActor_Preview: PreviewProvider  {
    static var previews: some View {
        GlobalActor()
            .preferredColorScheme(.dark)
    }
}
