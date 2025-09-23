//  print
import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = BackgroundThreadViewModel()
    var body: some View {
        ScrollView {
            Text("Load Data")
                .foregroundColor(.blue)
                .font(.system(size: 36, weight: .heavy)).ignoresSafeArea()
                .onTapGesture { vm.fetchData() }
            VStack(spacing: 0) {
                Text("Items")
                    .font(.largeTitle).bold()
                ForEach(vm.dataArray, id: \.self) { item in
                    Text(item)
                }
                .font(.system(size: 12, weight: .medium, design: .default))
            }
        }
    }
}
