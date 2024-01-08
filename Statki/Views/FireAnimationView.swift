import SwiftUI

struct FireAnimation: View {
    @State private var flameHeight: CGFloat = 20.0
    
    var body: some View {
        Image(systemName: "flame.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: flameHeight)
            .foregroundColor(.red)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    flameHeight = 30.0
                }
            }
    }
}
