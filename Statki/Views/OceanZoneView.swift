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
                    return .gray
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
        case .hit:
            return .red
        case .miss:
            return .green
        }
    }
    var forceVisibility: Bool
    private let circleScale = CGSize(width: 0.5, height: 0.5)
    private let oceanSquare = CGSize(width: 0.9, height: 0.9)
    
    
    
    @State private var isAnimating = false
    @State private var isOceanAnimating = false
    
    @State private var triangleOffset: CGSize = CGSize(width: 0, height: 200)
    
    @State private var triangleScale: CGFloat = 1.0
    
    @State private var targetLocation = CGPoint(x: 200, y: 200)
    @State private var referencePoint = CGPoint(x: 100, y: 100)
    
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(.black, lineWidth: 2)
                .background(.white)
            
            switch state {
            case .clear(let ship):
                if forceVisibility, ship != nil {
                    ScaledShape(shape: Rectangle(), scale: circleScale)
                        .fill(self.color)
                        .opacity(0.8)
                } else {
                    EmptyView()
                }
            case .miss:
                
                GeometryReader { geometry in
                    ZStack {
                        if isAnimating {
                            ScaledShape(shape: Rectangle(), scale: oceanSquare)
                                .fill(.blue)
                                .opacity(0.8)
                                .overlay(
                                    Circle()
                                        .stroke(lineWidth: 10)
                                        .foregroundColor(.white)
                                        .opacity(0.8)
                                        .frame(width: 50, height: 50)
                                        .scaleEffect(isOceanAnimating ? 1 : 0.1)
                                        .opacity(isOceanAnimating ? 0 : 1)
                                        .animation(Animation.easeOut(duration: 1).repeatForever(autoreverses: false))
                                        .onAppear() {
                                            self.isOceanAnimating = true
                                        }
                                )
                        } else {
                            RocketShape()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .scaleEffect(triangleScale)
                                .offset(triangleOffset)
                                .rotationEffect(.degrees(180))
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                                        triangleOffset = CGSize(width: geometry.size.width / 2 - 25, height: geometry.size.height / 2 - 25)
                                        triangleScale = 0.5
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            isAnimating = true
                                        }
                                    }
                                }
                        }
                    }
                }
                
            case .hit:
                GeometryReader { geometry in
                    ZStack {
                        if isAnimating {
                            ScaledShape(shape: Rectangle(), scale: oceanSquare)
                                .fill(.gray)
                                .opacity(0.8)
                                .overlay(
                                    FireAnimation().frame(width: 50, height: 50)
                                )
                        } else {
                            RocketShape()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .scaleEffect(triangleScale)
                                .offset(triangleOffset)
                                .rotationEffect(.degrees(180))
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                                        triangleOffset = CGSize(width: geometry.size.width / 2 - 25, height: geometry.size.height / 2 - 25)
                                        triangleScale = 0.5
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            isAnimating = true
                                        }
                                    }
                                }
                        }
                    }
                }
                
                
            }
        }
    }
    
}

struct FireAnimation: View {
    @State private var flameHeight: CGFloat = 10.0
    
    var body: some View {
        Image(systemName: "flame.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: flameHeight)
            .foregroundColor(.orange)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    flameHeight = 40.0
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


