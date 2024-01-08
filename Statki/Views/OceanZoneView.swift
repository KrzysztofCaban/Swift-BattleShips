import SwiftUI


// Widok pojedynczej komórki planszy
struct OceanZoneView: View {

    // Definicja możliwych stanów komórki
    @Binding var state: OceanZoneState

    // Zmienna przechowująca kolor komórki
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

    // Zmienna przechowująca informację o tym, czy komórka powinna być widoczna
    var forceVisibility: Bool

    // Stała przechowująca wielkość komórki
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
                // Wywołąnie animacji kliknięcia komórki
                OnChooseOceanZoneAnimation(zoneState: $state)
            }
        }
    }
    
}
