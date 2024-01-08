import SwiftUI

struct ContentView: View {
    // Referencja do obiektu Game, który jest dostępny w całej aplikacji
    @EnvironmentObject var game: Game

    // Zmienna przechowująca informację o tym, czy animacja zakończenia gry powinna być wyświetlona
    @State private var showEndAnimation = true

    // Zmienna kontrolująca przesunięcie planszy gry w dół, do gestu przeciągnięcia
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack {
                ToolbarView()
                VStack {
                    
                    // Wyświetlenie planszy przeciwnika
                    OceanView(ownership: .enemy)
                    Spacer()

                    // Wyświetlenie planszy gracza
                    OceanView(ownership: .player)

                }.overlay{
                    // Wyświetlenie animacji zakończenia gry
                    if game.gameMessage == "YOU WON !" {
                        FireworksView(isActive: $showEndAnimation)
                    } else if game.gameMessage == "YOU LOST !" {
                        FloodView(isActive: $showEndAnimation)
                    }
                }
                .onChange(of: game.gameMessage) { newMessage in
                    if newMessage == "YOU WON !" || newMessage == "YOU LOSE !" {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            showEndAnimation = true
                        }
                    }
                }
                // Obsługa gestu przeciągnięcia
                .gesture(DragGesture().onChanged { value in

                    // Jeśli przeciągnięcie jest w dół, przesuwamy widok
                    if value.translation.height > 0 {
                        withAnimation {
                            yOffset = min(value.translation.height, 150)
                        }
                    }
                }
                // Po zakończeniu gestu przeciągnięcia, resetujemy przesunięcie
                .onEnded { value in
                    if value.translation.height > 0 {
                        withAnimation {
                            yOffset = 0
                        }
                        
                        // Po pół sekundy resetujemy grę
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            game.reset()
                        }
                    }
                })
                .offset(y: yOffset)
            }
        }
    }
}
