// Code-along: Build powerful drag and drop in SwiftUI
// WWDC26 session 271 · https://developer.apple.com/videos/play/wwdc2026/271/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// App-defined types (CardValue, Card, Card.Group, Game, CardFaceView, …) belong to the session's card game.
// Explanations: ../README.md §8

// MARK: - [3:40] Add reorderable to the preview

#Preview {
    @Previewable @State var cards = [
        CardValue(rank: .ace, suit: .clubs),
        CardValue(rank: .ace, suit: .diamonds),
        CardValue(rank: .ace, suit: .hearts),
        CardValue(rank: .ace, suit: .spades)
    ]

    HStack {
        ForEach(cards) { card in
            CardFaceView(card: card)
        }
        .reorderable()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .reorderContainer(for: CardValue.self) { difference in
        cards.apply(difference: difference)
    }
    .padding()
    .background(.green.gradient)
}

// MARK: - [4:40] Add reorder container to the GameView

struct GameView: View {
    var game: Game

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 10
            let cardWidth = (proxy.size.width - 6 * spacing) / 7
            VStack {
                HStack(alignment: .top, spacing: spacing) {
                    Group {
                        RemainderView(game: game)
                        CardBackView()
                            .hidden()
                        ForEach(CardValue.Suit.allCases) { suit in
                            DestinationView(game: game, suit: suit)
                        }
                    }
                    .frame(width: cardWidth)
                }
                .padding(.bottom, 20)
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(0..<7) { index in
                        PileView(game: game, index: index)
                            .frame(width: cardWidth)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                // Add the reorder container modifier.
                .reorderContainer(for: CardValue.self, in: Card.Group.self) { difference in
                    game.moveCards(difference: difference)
                }
            }
        }
        .padding()
    }
}

// MARK: - [5:58] Add reorderable to PileView

struct PileView: View {
    var game: Game
    var index: Int
    @Query var cards: [Card]

    var body: some View {
        ZStack(alignment: .topLeading) {
            CardPlaceholderView()
            PileLayout {
                let index = firstFaceUpIndex
                // Iterates over the face down cards.
                ForEach(cards[..<index]) { card in
                    CardView(card: card)
                }
                // Iterates over the face up cards.
                ForEach(cards[index...], id: \.value) { card in
                    CardView(card: card)
                }
                .reorderable(collectionID: Card.Group.pile(index))
            }
        }
    }

    var firstFaceUpIndex: Int {
        cards.firstIndex { !$0.isFaceDown } ?? cards.endIndex
    }
}

// MARK: - [7:50] Add dragContainer to customize the reorderContainer modifier
// (GameView as at 4:40, with this added after .reorderContainer)

//  .dragContainer(for: CardValue.self) { cardID in
//      game.cardStack(startingAt: cardID)
//  }

// MARK: - [8:45] Add dragPreviewsFormation to customize how the dragged cards appear
// (added after .dragContainer)

//  .dragPreviewsFormation(.stack)

// MARK: - [9:14] Add dropPreviewsFormation to customize how dragged cards appear over a destination
// (added on the GeometryReader's VStack)

//  .dropPreviewsFormation(.stack)

// MARK: - [11:40] Add a drag configuration to allow move

struct RemainderView: View {
    @Query var cards: [Card]
    var game: Game

    var body: some View {
        Button {
            incrementCardIndex()
        } label: {
            ZStack {
                CardPlaceholderView()
                CardBackView()
                    .opacity(cards.isEmpty ? 0 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(cards.isEmpty)
        ZStack {
            CardPlaceholderView()
            if let currentCard {
                CardFaceView(card: currentCard.value)
                    .draggable(containerItemID: currentCard.value)
                    .opacity(currentCard.value == hiddenCard ? 0 : 1)
            }
        }
        .dragContainer(for: CardValue.self) { cardID in
            [cardID]
        }
        // Add the drag configuration to allow me.
        .dragConfiguration(DragConfiguration(allowMove: true))
    }
}

// MARK: - [12:05] Add a drop destination modifier and configure it
// (on GameView's piles HStack, after .reorderContainer / .dragContainer / .dragPreviewsFormation)

//  .dragConfiguration(DragConfiguration(allowMove: true))
//  // Add a drop destination to accept inserts
//  .dropDestination(for: CardValue.self) { newCards, session in
//      if let destination = session.reorderDestination(
//          for: CardValue.self, in: Card.Group.self) {
//          game.insertCards(newCards, to: destination)
//      }
//  }
//  // Configure where cards will go when reordering,
//  // and accept them by move.
//  .dropConfiguration { session in
//      // Calculate which pile is being dragged over.
//      let alignedX = session.location.x - 0.5 * spacing
//      let pile = Int(alignedX / (cardWidth + spacing))
//      let destination = ReorderDifference<CardValue, Card.Group>
//          .Destination(position: .end, collectionID: .pile(pile))
//      // Check if the move is allowed.
//      let allowed = session.suggestedOperations.contains(.move)
//      && game.validateMove(session: session, destination: destination)
//      let operation: DropOperation = allowed ? .move : .forbidden
//      return DropConfiguration(operation: operation, destination: destination)
//  }
