import SwiftUI

// Animacja przegrania gry
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
