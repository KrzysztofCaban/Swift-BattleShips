import Foundation

class Fleet {
    static let shipsInFleet:[(name: String, length: Int)] = [("PT Boat", 2),
                                                         ("Submarine", 3),
                                                         ("Destroyer", 3),
                                                         ("Battleship", 4),
                                                         ("Aircraft Carrier", 5)]
    var ships: [Ship]
    
    init() {
        ships = [Ship]()
    }

    //RETURN TRUE IF ALL SHIPS IN FLEET ARE DESTROYED
    func isDestroyed() -> Bool {
        return !ships.contains(where:{!$0.isSunk()})
    }
    
    //RETURN SHIP AT GIVEN COORDINATE
    //RETURN NIL IF NO SHIP AT GIVEN COORDINATE
    func ship(at location: Coordinate) -> Ship? {
        return ships.first(where:{$0.occupies(location)})
    }
    
    //DEPLOY FLEET IN RANDOM LOCATIONS
    func deploy(on ocean: Ocean) {
        ships.removeAll()
        for ship in Fleet.shipsInFleet {
            //GET ALL POSSIBLE LOCATIONS
            //CHECK IF SHIP CAN FIT WITHOUT INTERSECTING WITH OTHER ALREADY DEPLOYED SHIPS
            let fleetCoordinates = self.coordinates()
            let oceanCoordinates = ocean.locationsThatFit(length: ship.length)
            let possibleLocations = oceanCoordinates.filter {Set($0).intersection(fleetCoordinates).isEmpty}
            guard (possibleLocations.count > 0) else {
                assertionFailure("Cannot fit ship in ocean.!")
                return
            }
            
            //PICK ONE RANDOM LOCATION FROM POSSIBLE LOCATIONS
            let randomIndex = Int.random(in: 0..<possibleLocations.count)
            let shipCoordinates = possibleLocations[randomIndex]
            let deployedShip = Ship(ship.name, coordinates: shipCoordinates)
            ships.append(deployedShip)
        }
    }
    
    private func coordinates() -> [Coordinate] {
        let coordinates = ships.map {$0.compartments.map {$0.location}}
        return Array(coordinates.joined())
    }
}
