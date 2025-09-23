import SwiftUI
import Foundation

let df = Foundation.Date()
let fullDate = df.formatted() // example: "6/7/2021, 9:42 AM"
let onlyDate = df.formatted(date: .long, time: .omitted) // "6/7/2021"
let onlyTime = df.formatted(date: .omitted, time: .shortened) // "9:42AM"


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "apple.logo")
                .imageScale(.large)
                // .foregroundColor(.accentColor)
                .font(.largeTitle)
            
            Text(("Created on"))
            Text(onlyDate)
            Text(onlyTime)
//            Text("at ", onlyTime)
            Text("")
            Text("")
            Text("Took \(time.components.seconds)")
                 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

