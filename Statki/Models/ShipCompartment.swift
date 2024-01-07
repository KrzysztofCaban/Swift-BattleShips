import Foundation

//REPRESENTS A SINGLE COMPARMENT WITHIN A SHIP
class ShipCompartment {
    var location: Coordinate = .zero
    var flooded: Bool = false
    
    init(location: Coordinate, flooded:Bool = false) {
        self.location = location
        self.flooded = flooded
    }
}

extension ShipCompartment: CustomStringConvertible {
    var description: String {
        return location.description
        }
}
