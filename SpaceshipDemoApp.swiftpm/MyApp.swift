// SpaceshipDemoApp
// 

import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.iypc.SpaceshipDemoApp", category: "SpaceshipDemoApp")

@main
struct AISpaceshipDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    logger.info("App launched")
                }
        }
    }
}
