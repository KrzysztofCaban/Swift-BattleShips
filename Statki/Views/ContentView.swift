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


struct FireworksView: View {
    @Binding var isActive: Bool
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            Text("🎆")
                .font(.system(size: 300))
                .foregroundColor(.white)
                .opacity(opacity)
                .onAppear {
                    let baseAnimation = Animation.easeInOut(duration: 1)
                    let repeated = baseAnimation.repeatForever(autoreverses: true)
                    withAnimation(repeated) {
                        opacity = 0.0
                    }
                }
        }
        .opacity(isActive ? 1 : 0)
    }
}

struct FloodView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.7).ignoresSafeArea()
            
            Text("🚢")
                .font(.system(size: 300))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 90))
        }
        .opacity(isActive ? 1 : 0)
    }
}


