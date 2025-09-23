// MemoryGameView.swift  (View)
// Reflects the model
// Stateless generally...

import SwiftUI
// week 4 18:33

struct MemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    var body: some View {
        VStack {
            ScrollView {
                cards
                    .animation(.default, value: viewModel.cards)
            }
            Button("Shuffle") {
                viewModel.model.shuffle()
            }
            .foregroundStyle(.blue)
            .bold()
        }
    }
    
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 65), spacing: 4)], spacing: 4) {
            ForEach(viewModel.cards) { card in
                VStack(spacing: 0) {
                    CardView(card)
                        .aspectRatio(2/3, contentMode: .fit)
                        .onTapGesture {
                            print("onTapGesture")
                            viewModel.choose(card)
                        }
                }
            }
            .foregroundColor(.cardinalRed)
        }
        .padding()
    }
}

struct CardView: View {
    let card: MemoryGame<String>.Card
    
    init(_ card: MemoryGame<String>.Card) {
        self.card = card
    }
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 8, style: .circular)
            
            if card.isFaceUp {
                shape.fill(.white)
                shape.strokeBorder(lineWidth: 2)
                
                Text(card.content)
                    .font(.system(size: 65))
                    .minimumScaleFactor(0.01)
                    .aspectRatio(contentMode: .fill)
            }
            else {
                shape.fill()
                VStack {
                    Text("Stanford")
                    Image("stanfordtree")
                        .resizable()
                        .frame(width: 40, height: 50)
                    Text("\(card.id)")
                }
                .scaledToFit()
                .font(.footnote)
                .foregroundStyle(.white)
                .bold()
            }
        }
        .opacity(card.isFaceUp || !card.isMatched ? 1 : 0)
    }
}


struct MemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGameView(viewModel: EmojiMemoryGame())
            .preferredColorScheme(.dark)
    }
}




