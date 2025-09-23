//  AsyncAwait  09/06/2025-1
// 
import SwiftUI

struct User: Identifiable  {
    let name: String
    var email: String
    var id: String = UUID().uuidString
}

class AsyncAwaitViewModel: ObservableObject  {
    @Published var users = [User]()
    
    init()  {
        Task  {
            print("Start Task...")
            await fetchData()
            print("Completed Task")
        }
    }
    
    func fetchData() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000) // sleep 5 seconde
        
        let users: [User] = [
            .init(name: "Ralph Krueger", email: "ralph@iypcmail.com"),
            .init(name: "Kathy Hartwig", email: "kathy@iypcmail.com"),
            .init(name: "Joanne Marshke", email: "joanne@iypcmail.com"),
            .init(name: "Mike Krueger", email: "mike@iypcmail.com"),
            .init(name: "Carol Johnson", email: "carol@iypcmail.com"),
            .init(name: "Christine Kresse", email: "christine@iypcmail.com"),
            .init(name: "Bubba Clavette", email: "bubba@iypcmail.com"),
            .init(name: "Gerald Krueger", email: "gman@iypcmail.com")
        ]
        self.users = users
    }
}

struct ContentView: View {
    @StateObject var viewModel = AsyncAwaitViewModel()
    var body: some View {
        List {
            ForEach(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(" name: \(user.name)")
                    Text("email: \(user.email)")
                    Text("id: \(user.id)")
                        .foregroundColor(.forestGreen)
                }
                .multilineTextAlignment(.leading)
                .font(.system(size:  18, weight: .bold, design: .monospaced))
            }
        }
        
    }
}


//struct ContentView_Provider: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .preferredColorScheme(.dark)
//    }
//}

