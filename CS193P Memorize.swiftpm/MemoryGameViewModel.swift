// MemoryGameViewModel.swift (ViewModel)
// Binds model to view
// Interpreter between model and view
// 02/10/2023

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    static var emojis = ["🚂", "✈️", "🚜", "🚀", "🛸", "🛩️", "🚁", "🛵", "🛶", "🛺", "🚔", "🚲", "🛰️", "🏍️", "🚆", "🚃", "🚦", "🚥", "🗽", "🗼", "🏰", "🏯", "🏟️", "🎡" , "🪝", "⚓️", "🏢", "🗼", "🗽", "🚴‍♂️"]
    
    static var emojiSet: Set<String>?
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            EmojiMemoryGame.emojis[pairIndex]
        }
    }
    
    @Published var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
    
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
    // MARK: - Intent(s)
    func choose(_ card: MemoryGame<String>.Card) {
        // objectWillChange.send()
        print("ViewModel: func choose()")
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    static func copyArray(_ emojiArray: inout Array<String>, _ set: inout Set<String> )  {
        for item in emojiArray {
            set.update(with: item)
        }
    }
    
}


