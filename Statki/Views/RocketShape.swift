import SwiftUI

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
