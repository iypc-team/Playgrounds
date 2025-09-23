import SwiftUI

struct StateVsObserved: View  {
//    @StateObject is persistent
//    @ObservedObject is NOT persistent
    @StateObject var viewModel = CounterViewModel()
    
    var body: some View  {
        VStack  {
            Spacer()
            Text("Count: \(viewModel.count)")
            Spacer()
            HStack  {
                Button("Increase Count")  {
                    viewModel.incrementCount() 
                }
                Spacer()
                Button("Decrement Count")  {
                    viewModel.decrementCount()
                }
            }
            .foregroundColor(.blue)
        }
        .padding(.all)
        .font(.system(size: 20, weight: .bold, design: .monospaced))
    }
}


struct StateVsObserved_Previews: PreviewProvider  {
    static var previews: some View  {
        StateVsObserved()
            .preferredColorScheme(.dark)
    }
}
