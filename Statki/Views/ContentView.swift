import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: Game
    @State private var showFireworks = false
    @State private var showFlood = false
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
                        FireworksView(isActive: $showFireworks)
                    } else if game.gameMessage == "YOU LOST !" {
                        FloodView(isActive: $showFlood)
                    }
                }
                .onChange(of: game.gameMessage) { newMessage in
                    if newMessage == "YOU WON !" {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            showFireworks = true
                        }
                    } else if newMessage == "YOU LOST !" {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            showFlood = true
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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            Text("🎆")
                .font(.system(size: 100))
                .foregroundColor(.white)
                .onTapGesture {
                    isActive = false
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
            
            Text("💦")
                .font(.system(size: 100))
                .foregroundColor(.white)
                .onTapGesture {
                    isActive = false
                }
        }
        .opacity(isActive ? 1 : 0)
    }
}

