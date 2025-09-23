// GrammarAgreement
import SwiftUI

struct ContentView: View {
    @State private var count: Int = 0
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .font(.system(size: 125, weight: nil, design: nil))
                .imageScale(.large)
                .foregroundColor(.cardinalRed)
            Text("Hello, world Kiss my ass!")
                .padding(25)
            Text("^[\(count)](inflect: true)")
            Spacer(minLength: 100)
            
            HStack {
                Button("Add") { count += 1 }
                    .background(Color.forestGreen)
                Spacer()
                Button("Remove") { count -= 1 }
                    .background(Color.cardinalRed)
                    
            }
            .padding(12)
            .border(Color.white)
            .foregroundColor(.white)
            
            .font(.system(.largeTitle, design: .default, weight: .regular))
        }
        .padding(22)
        .font(.system(.largeTitle, design: .default, weight: .regular))
    }
}
