import Foundation

class Fleet {
    // Definiujemy statyczny array, który zawiera informacje o statkach w flotylli
    static let shipsInFleet:[(name: String, length: Int)] = [("PT Boat", 2),
                                                         ("Submarine", 3),
                                                         ("Destroyer", 3),
                                                         ("Battleship", 4),
                                                         ("Aircraft Carrier", 5)]

    // Definiujemy array, który zawiera statki w flotylli
    var ships: [Ship]
    
    // Inicjalizujemy klasy Fleet
    init() {
        ships = [Ship]()
    }

    // Funkcja sprawdzająca, czy wszystkie statki w floty zostały zniszczone
    func isDestroyed() -> Bool {
        // Jeśli nie ma statku, który nie jest zatopiony, zwracamy true
        return !ships.contains(where:{!$0.isSunk()})
    }
    
    // Funkcja zwracająca statek na podanych współrzędnych
    // Jeśli na podanych współrzędnych nie ma statku, zwraca nil
    func ship(at location: Coordinate) -> Ship? {
        // Zwracamy pierwszy statek, który zajmuje podane współrzędne
        return ships.first(where:{$0.occupies(location)})
    }
    
    // Funkcja rozmieszczająca flotę w losowych lokalizacjach na oceanie
    func deploy(on ocean: Ocean) {
        // Usuwamy wszystkie statki z arraya
        ships.removeAll()

        // Dla każdego statku floty
        for ship in Fleet.shipsInFleet {
            // Pobieramy wszystkie możliwe lokalizacje
            // Sprawdzamy, czy statek zmieści się bez przecięcia z innymi już rozmieszczonymi statkami
            let fleetCoordinates = self.coordinates()
            let oceanCoordinates = ocean.locationsThatFit(length: ship.length)
            let possibleLocations = oceanCoordinates.filter {Set($0).intersection(fleetCoordinates).isEmpty}
            // Jeśli nie ma możliwych lokalizacji, zwracamy błąd
            guard (possibleLocations.count > 0) else {
                assertionFailure("Cannot fit ship in ocean.!")
                return
            }
            
            // Wybieramy jedną losową lokalizację z możliwych lokalizacji
            let randomIndex = Int.random(in: 0..<possibleLocations.count)
            let shipCoordinates = possibleLocations[randomIndex]
            // Tworzymy statek i dodajemy go do deklaracji floty
            let deployedShip = Ship(ship.name, coordinates: shipCoordinates)
            ships.append(deployedShip)
        }
    }
    
    // Prywatna funkcja zwracająca wszystkie współrzędne zajmowane przez statki w flotylli
    private func coordinates() -> [Coordinate] {
        let coordinates = ships.map {$0.compartments.map {$0.location}}
        return Array(coordinates.joined())
    }
}
