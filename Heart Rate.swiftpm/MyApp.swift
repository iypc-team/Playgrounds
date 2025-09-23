import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HeartRateView(data: HeartData(beatsPerMinute: 78))
            
        }
    }
}
