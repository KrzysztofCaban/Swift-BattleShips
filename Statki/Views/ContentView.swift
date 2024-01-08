import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: Game
    @State private var showEndAnimation = true
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack {
                ToolbarView()
                VStack {
                    OceanView(ownership: .enemy)
                    Spacer()
                    OceanView(ownership: .player)
                }.overlay{
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
                .gesture(DragGesture().onChanged { value in
                    if value.translation.height > 0 {
                        
                        withAnimation {
                            yOffset = min(value.translation.height, 150)
                        }
                    }
                }
                    .onEnded { value in
                        if value.translation.height > 0 {
                            withAnimation {
                                yOffset = 0
                            }
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
