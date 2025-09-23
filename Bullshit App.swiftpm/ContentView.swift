import SwiftUI

struct ContentView: View {
    var body: some View {
        let its = interestingShit()
        ZStack {
            LinearGradient(colors: [Color(.black), Color(.green),],
                           startPoint: .topLeading, 
                           endPoint: .bottomTrailing)
            //.edgesIgnoringSafeArea(.all)
            VStack {
                Button("WTF"){
                    print("wtf")
                }
                Button("Extra"){
                    print("extra")
                }
                .padding(5)
                Button("Bull"){
                    print("\nbullshit...")
                    for item in its.colors {
                        print(item)
                    }
                }
                .padding(5)
                Button("Int8"){
                    var minint: Int8
                    minint = Int8.min
                    var maxint: Int8
                    maxint = Int8.max
                    print("Int8: min ", minint)
                    print("Int8: max", maxint)
                }
                .padding(5)
                Button("Int16 "){
                    var minint: Int16
                    minint = Int16.min
                    var maxint:Int16
                    maxint=Int16.max
                    print("Int16 min", minint)
                    print("Int16 max", maxint)
                }
                .padding(5)
                Button("Int32"){
                    var minint:Int32
                    minint = Int32.min
                    var maxint:Int32 
                    maxint = Int32.max
                    print("Int32 min", minint)
                    print("Int32 max", maxint)
                }
                .padding(5)
                Button("Int64"){
                    var minint:Int64
                    minint = Int64.min
                    var maxint:Int64
                    maxint = Int64.max
                    print("Int64 min", minint)
                    print("Int64 max", maxint)
                }
                .padding(5)
            }
            .buttonBorderShape(.roundedRectangle)
            .background(.green)
            .foregroundColor(.white)
            .bold()
            .font(.largeTitle)
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .preferredColorScheme(.light)
    }
}
