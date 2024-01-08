import SwiftUI

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
