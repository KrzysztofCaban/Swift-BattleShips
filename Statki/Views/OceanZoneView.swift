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
