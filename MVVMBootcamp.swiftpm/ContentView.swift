import SwiftUI

final class ManagerClass {
    
    func getData() async throws -> String  {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        print("ManagerClass async with 5 second delay.\n")
        return "ManagerClass Data"
    }
}

actor ManagerActor  {
    func getData() async throws -> String  {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        print("ManagerActor async with 5 second delay.\n")
        return "ManagerActor data"
    }
}

struct ContentView: View {
    @StateObject private var viewModel = MVVMBootcampViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .foregroundColor(.red)
                .font(.system(size: 150))
                .padding(20)
            Text("Hello, world...")
            Text("Kiss my rosie red ass!")
            Text("pressCount: \(viewModel.pressCount)")
//            Text(viewModel.managerClass.getData())
            
            Spacer()
            HStack {
                Button("Click Here")  {
                    viewModel.onCallToActionButton()
                }
                .foregroundColor(.green)
                Spacer()
                Button("Cancel Tasks")  {
                    viewModel.cancelTasks()
                }
                .foregroundColor(.red)
            }
            .padding(10)
        }
        .font(.system(size: 22, weight: .bold, design: .default))
    }
}


struct ContentView_Provider: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
