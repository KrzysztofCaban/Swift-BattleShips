import Foundation

class Ship {
    var name: String
    var compartments: [ShipCompartment]
    var length: Int {return compartments.count}
    
    init(_ name: String, coordinates: [Coordinate]) {
        self.name = name
        self.compartments = [ShipCompartment]()
        for coordinate in coordinates {
            compartments.append(ShipCompartment(location: coordinate))
        }
    }
    
    //RETURN SHIP'S COORDINATES
    func coordinates() -> [Coordinate] {
        return Array(compartments.map {$0.location})
    }
    
    //RETURN TRUE IF SHIP OCCUPIES GIVEN COORDINATE
    func occupies(_ location: Coordinate) -> Bool
    {
        return compartments.contains(where:{$0.location == location})
    }
    
    //RETURN TRUE IF ALL COMPARTMENTS ARE FLOODED
    func isSunk() -> Bool
    {
        //SHIP IS NOT SUNK IF AT LEAST ONE COMPARTMENT IS NOT FLOODED
        return !compartments.contains(where: {!$0.flooded})
    }
    
    //HIT AT GIVEN COORDINATE
    func hit(at location: Coordinate) {
        if let compartment = compartments.first(where: {$0.location == location}) {
            compartment.flooded = true
        }
    }
}

extension Ship: CustomStringConvertible {
    var description: String {
        return name + ": " + compartments.description
        }
}

