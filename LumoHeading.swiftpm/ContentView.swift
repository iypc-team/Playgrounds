// LumoHeading  09/19/2025-3
// 
// 

import SwiftUI
import CoreLocation
import Combine   // optional, only if you also want a Combine publisher

struct CompassView: View {
    
//    print("CompassView")
    @StateObject private var cvm = CompassViewModel()
    var hp = HeadingProvider()
    
    var body: some View {
        VStack {
            Text("Heading.description: \(cvm.heading)")
                .font(.title2)
                .padding()
            Text("Heading.magnitude: \(cvm.heading.magnitude)")
                .font(.title2)
                .padding()
            // You could rotate an arrow image using `cvm.yaw`
            Image(systemName: "arrow.up")
                .rotationEffect(.radians(cvm.heading))
                .font(.largeTitle)
                .padding()
        }
        .onAppear {  }
        .onDisappear {  }
        Spacer()
        HStack(alignment: .center, spacing: 20, content: {
            Button("Start", action: {
                print("Start pressed")
                hp.locationManager.startUpdatingHeading()
                cvm.provider.resume()
                print()
            })
            .frame(width: 75,height: 30)
            .background(Color.green)
            .foregroundColor(.black)
            
            Button("Pause", action: {
                print("Pause pressed")
                hp.isPaused.toggle()
                hp.locationManager.pausesLocationUpdatesAutomatically.toggle()
            })
            .frame(width: 75,height: 30)
            .background(Color.yellow)
            .foregroundColor(.black)
            
            
            Button("Stop", action: {
                print("Stop pressed")
                cvm.task?.cancel()
                print("task: \(cvm.task!)")
                hp.locationManager.stopUpdatingHeading()
            })
            .frame(width: 75,height: 30)
            .background(Color.red)
            .foregroundColor(.black)
        })
        .font(.system(size: 18, weight: .bold, design: .default))
        .padding(30)
    }
}
