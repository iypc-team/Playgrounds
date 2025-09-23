// MemoryGameModel.swift (Model)
// UI Independant data and  game logic
// 02/10/2023

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable  {
    private(set) var cards: Array<Card>
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            let content: CardContent = createCardContent(pairIndex)
            cards.append(Card(content: content, id: "\(pairIndex + 1)a"))
            cards.append(Card(content: content, id: "\(pairIndex + 1)b"))
        }
//        shuffle()
//        print("Model:\tMemoryGame<CardContent>")
    }
    
    // Computed var indexOfTheOneAndOnlyFaceUpCard // Lecture 5 1:10:00
    var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { return cards.indices.filter { index in cards[index].isFaceUp }.only}
        set { cards.indices.forEach { cards[$0].isFaceUp = (newValue == $0) } }
    }
    
    mutating func choose(_ card: Card) {
        // Lecture 9 1:03:53
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }) {
            if !cards[chosenIndex].isFaceUp && !cards[chosenIndex].isMatched {
                cards[chosenIndex].isFaceUp = true
                if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                    if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                        cards[chosenIndex].isMatched = true
                        cards[potentialMatchIndex].isMatched = true
                    } else { 
                        indexOfTheOneAndOnlyFaceUpCard = chosenIndex 
                    }
                    cards[chosenIndex].isFaceUp = true
                }
            }
            print("Model: mutating func choose")
            print("chosenIndex: \(chosenIndex)")
            print("Id: \(card.id)")
            print("isFaceUp: \(card.isFaceUp)")
            print("isMatched: \(card.isMatched)\n")
        }
    }
    
    func index(of: Card) -> Int? {
        for index in 0..<cards.count {
            if cards[index].id == of.id {
                print("Model:  func index(of: Card) \(index)")
                return index
            }
        }
        return nil
    }
    
    mutating func shuffle() {
        cards.shuffle()
//        print(cards)
    }
    
    struct Card: Equatable, Identifiable, CustomDebugStringConvertible {
//        static func == (lhs: Card, rhs: Card) -> Bool {
//            return lhs.isFaceUp == rhs.isFaceUp && lhs.isMatched == rhs.isMatched && lhs.content == rhs.content
//        }
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: String
        var debugDescription: String {
            return "id: \(id): \ncontent: \(content) \nFaceUp: \(isFaceUp) \nMatched: \(isMatched)"
        }
    }
}


