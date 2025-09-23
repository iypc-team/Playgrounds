import SwiftUI

@main
struct MyApp: App {
    let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            MemoryGameView(viewModel: game)
        }
    }
}
