import Foundation

class Ship {
    // Zmienna przechowująca nazwę statku
    var name: String
    // Array przechowujący części statku
    var compartments: [ShipCompartment]
    // Właściwość obliczeniowa zwracająca długość statku (liczbę komór)
    var length: Int {return compartments.count}
    
    // Inicjalizator klasy Ship
    init(_ name: String, coordinates: [Coordinate]) {
        self.name = name
        self.compartments = [ShipCompartment]()
        // Dla każdej współrzędnej tworzymy część statku
        for coordinate in coordinates {
            compartments.append(ShipCompartment(location: coordinate))
        }
    }
    
    // Funkcja zwracająca współrzędne statku
    func coordinates() -> [Coordinate] {
        return Array(compartments.map {$0.location})
    }
    
    // Funkcja sprawdzająca, czy statek zajmuje daną współrzędną
    func occupies(_ location: Coordinate) -> Bool
    {
        return compartments.contains(where:{$0.location == location})
    }
    
    // Funkcja sprawdzająca, czy statek jest zatopiony
    func isSunk() -> Bool
    {
       // Statek nie jest zatopiony, jeśli przynajmniej jedna część nie jest zalana
        return !compartments.contains(where: {!$0.flooded})
    }
    
    // Funkcja symulująca trafienie w statek na danej współrzędnej
    func hit(at location: Coordinate) {
        if let compartment = compartments.first(where: {$0.location == location}) {
            compartment.flooded = true
        }
    }
}

// Rozszerzenie klasy Ship o protokół CustomStringConvertible
extension Ship: CustomStringConvertible {
    // Właściwość obliczeniowa zwracająca opis statku
    var description: String {
        return name + ": " + compartments.description
        }
}

