import Foundation

// Klasa ShipCompartment reprezentuje pojedynczą część w statku
class ShipCompartment {
    // Właściwość przechowująca lokalizację części statku
    var location: Coordinate = .zero
     // Właściwość przechowująca informację, czy część jest zalana
    var flooded: Bool = false
    
    // Inicjalizator klasy ShipCompartment
    init(location: Coordinate, flooded:Bool = false) {
        self.location = location
        self.flooded = flooded
    }
}

// Rozszerzenie klasy ShipCompartment o protokół CustomStringConvertible
extension ShipCompartment: CustomStringConvertible {
    var description: String {
        return location.description
        }
}
