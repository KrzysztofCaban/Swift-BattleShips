import SwiftUI

// Animacja niecelnego strzału
struct WaterAnimation: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1
    var body: some View {
        Circle()
            .stroke(lineWidth: 10)
            .foregroundColor(.white)
            .opacity(0.8)
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    scale = 0.8
                opacity = 0
                }
            }
    }
}
