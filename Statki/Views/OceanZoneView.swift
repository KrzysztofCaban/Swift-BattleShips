import SwiftUI


//REPRESENTATION OF SINGLE ZONE IN AN OCEAN
struct OceanZoneView: View {
    @Binding var state: OceanZoneState
    var color: Color {
        switch state {
        case .clear(let ship):
            if let ship = ship {
                switch ship.length {
                case 5:
                    return .green
                case 4:
                    return .purple
                case 3:
                    return .orange
                case 2:
                    return .yellow
                default:
                    return .white
                }
            } else {
                return .clear
            }
        default:
            return .white
        }
    }
    var forceVisibility: Bool
    private let circleScale = CGSize(width: 0.7, height: 0.7)
    
    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(.black, lineWidth: 1)
                .background(.white)
                .aspectRatio(1,contentMode: .fill)
            
            switch state {
            case .clear(let ship):
                if forceVisibility, ship != nil {
                    ScaledShape(shape: Circle(), scale: circleScale)
                        .fill(self.color)
                        .opacity(0.8)
                } else {
                    EmptyView()
                }
            case .miss, .hit:
                OnChooseOceanZoneAnimation(zoneState: $state)
                
            }
        }
    }
    
}

struct OnChooseOceanZoneAnimation: View {
    @Binding var zoneState: OceanZoneState
    private let oceanSquare = CGSize(width: 0.95, height: 0.95)
    @State private var isAnimating = false
    @State private var triangleOffset: CGSize = CGSize(width: 0, height: 200)
    @State private var triangleScale: CGFloat = 2.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isAnimating {
                    switch zoneState {
                    case .hit:
                        ScaledShape(shape: Rectangle(), scale: oceanSquare)
                            .fill(.gray)
                            .opacity(0.6)
                            .overlay(
                                FireAnimation().frame(width: 50, height: 50)
                            )
                    default:
                        ScaledShape(shape: Rectangle(), scale: oceanSquare)
                            .fill(.blue)
                            .opacity(0.8)
                            .overlay(
                                WaterAnimation().frame(width: 50, height: 50)
                            )
                    }
                    
                } else {
                    RocketShape()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                        .scaleEffect(triangleScale)
                        .offset(triangleOffset)
                        .rotationEffect(.degrees(180))
                        .onAppear {
                            animateRocket(geometry: geometry)
                        }
                }
            }
        }
    }
    
    func animateRocket(geometry: GeometryProxy) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            triangleOffset = CGSize(width: geometry.size.width / 2 - 25, height: geometry.size.height / 2 - 25)
            triangleScale = 0.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isAnimating = true
            }
        }
    }
}



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




struct RocketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Ścieżka SVG przekształcona na SwiftUI Path
        path.move(to: CGPoint(x: rect.width * 0.304, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.299, y: rect.height * 0.224))
        path.addCurve(to: CGPoint(x: rect.width * 0.388, y: rect.height * 0.079),
                      control1: CGPoint(x: rect.width * 0.299, y: rect.height * 0.17),
                      control2: CGPoint(x: rect.width * 0.337, y: rect.height * 0.13))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.224))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.648, y: rect.height * 0.773))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.773))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.924))
        path.addLine(to: CGPoint(x: rect.width * 0.304, y: rect.height * 0.924))
        path.addLine(to: CGPoint(x: rect.width * 0.304, y: rect.height * 0.773))
        path.addLine(to: CGPoint(x: rect.width * 0.157, y: rect.height * 0.773))
        path.closeSubpath()
        
        return path
    }
}



struct OceanZoneView_Previews: PreviewProvider {
    static var previews: some View {
        OceanZoneView(state: .constant(.miss), forceVisibility: true)
    }
}


