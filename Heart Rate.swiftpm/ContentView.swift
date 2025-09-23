import SwiftUI
import UIKit
import Foundation

// Passing an ObservableObject to automaticaly SwiftUI views
class HeartData: ObservableObject {
    @Published var beatsPerMinute: Int
    
    init(beatsPerMinute: Int) {
        self.beatsPerMinute = beatsPerMinute
    }
}

struct HD {
    static func changeRate(bpm: Int) {
        print(bpm)
    }
}

struct HeartRateView: View {
    @ObservedObject var data: HeartData
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.cardinalRed, Color.pink, Color.gray, Color.white],
                           startPoint: .top, 
                           endPoint: .bottom)
            
            VStack {
                Spacer()
                Text("Heart Rate")
                    .font(.largeTitle)
                Text("\(data.beatsPerMinute)  BPM")
                    .font(.title)
                Text("(beats per minute)")
                    .font(.footnote)
                Spacer()
                HStack {
                    
                }
            }
            .foregroundStyle(.white)
            .bold()
        }
    }
}

class HeartRateViewController: UIViewController {
    weak var data: HeartData?
//    let heartRateView? = HeartRateView(data: HeartData.init(beatsPerMinute: 75)) } // SwiftUI view
    let heartRateView? = HeartRateView()
    let hostingController = UIHostingController(rootView: heartRateView)
    
    init(data: HeartData) {
        self.data = data
        let heartRateView = HeartRateView(data: data)
        self .hostingController = UIHostingController(rootView: heartRateView)
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 



