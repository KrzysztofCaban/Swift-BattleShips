import Foundation
import Combine

final class Game: ObservableObject {
    
    let numCols: Int
    let numRows: Int
    var playerOcean: Ocean
    var enemyOcean: Ocean
    var playerFleet: Fleet
    var enemyFleet: Fleet
    @Published var playerZoneStates = [[OceanZoneState]]()
    @Published var enemyZoneStates = [[OceanZoneState]]()
    @Published var gameMessage = ""
    @Published var turnCounter: Int = 0
    var over: Bool {
        return playerFleet.isDestroyed() || enemyFleet.isDestroyed()
    }
    
    var lastHittedLocation: Coordinate?
    var suggestedLocation: Coordinate?
    var directionToLastHit: Direction?
    
    
    init(numCols: Int, numRows: Int) {
        self.numRows = numRows
        self.numCols = numCols
        self.playerOcean = Ocean(numCols: numCols, numRows: numRows)
        self.playerFleet = Fleet()
        self.enemyOcean = Ocean(numCols: numCols, numRows: numRows)
        self.enemyFleet = Fleet()
        reset()
    }
    
    // NEW GAME
    func reset() {
        self.playerFleet.deploy(on: self.playerOcean)
        self.enemyFleet.deploy(on: self.enemyOcean)
        self.playerZoneStates = defaultZoneStates(for: self.playerFleet)
        self.enemyZoneStates = defaultZoneStates(for: self.enemyFleet)
        self.gameMessage = ""
        self.turnCounter = 0
        self.lastHittedLocation = nil
        self.directionToLastHit = nil
        self.suggestedLocation = nil
    }
    
    
    // HANGLE USER TAP
    func enemyZoneTapped(_ location: Coordinate) -> ShipHitStatus {
        guard !over else {
            gameMessage = "YOU LOST !"
            return .over
        }

        var status: ShipHitStatus = .miss
        if case .clear = enemyZoneStates[location.x][location.y] {
            self.turnCounter += 1
            if let hitShip = enemyFleet.ship(at: location) {
                hitShip.hit(at: location)
                enemyZoneStates[location.x][location.y] = .hit
                if hitShip.isSunk() {
                    gameMessage = "You sunk enemy \(hitShip.name)!"
                    status = .sunk
                } else {
                    gameMessage = "Your hit at x:\(location.x), y:\(location.y)"
                    status = .hit
                }
            } else {
                enemyZoneStates[location.x][location.y] = .miss
                gameMessage = "You missed at x:\(location.x), y:\(location.y)"
            }

            Task {
                let duration = UInt64(0.7 * 1_000_000_000) // nanoseconds
                await self.delayedAction(for: duration)
            }
        }
        return status
    }

    func playerZoneTapped(_ location: Coordinate) -> ShipHitStatus {
        guard !over else {
            gameMessage = "YOU WON !"
            return .over
        }

        var status: ShipHitStatus = .miss
        if case .clear = playerZoneStates[location.x][location.y] {
            if let hitShip = playerFleet.ship(at: location) {
                hitShip.hit(at: location)
                playerZoneStates[location.x][location.y] = .hit
                if hitShip.isSunk() {
                    gameMessage = "Enemy sunk your \(hitShip.name)!"
                    status = .sunk

                    self.lastHittedLocation = nil
                    self.directionToLastHit = nil
                    self.suggestedLocation = nil
                } else {
                    gameMessage = "Enemy hited at x:\(location.x), y:\(location.y)"
                    status = .hit
                }
            } else {
                playerZoneStates[location.x][location.y] = .miss
                gameMessage = "Enemy miss at x:\(location.x), y:\(location.y)"
            }
        }
        return status
    }

    // CREATE 2DIMENSIONAL ARRAY WITH ALL ZONES SET TO .clear
    private func defaultZoneStates(for fleet: Fleet) -> [[OceanZoneState]] {
        var states = [[OceanZoneState]]()
        for x in 0..<self.numCols {
            states.append([])
            for y in 0..<self.numRows {
                let location = Coordinate(x: x, y: y)
                let ship = fleet.ship(at: location)
                states[x].append(.clear(ship))
            }
        }
        return states
    }

    func delayedAction(for nanoseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: nanoseconds)
        await MainActor.run {
            self.performEnemyRandomFire()
        }
    }

    func getNearestLocations(to lastHittedLocation: Coordinate, from clearLocations: [Coordinate]) -> [Coordinate] {
        clearLocations.filter { clearLocation in
            let dx = abs(clearLocation.x - lastHittedLocation.x)
            let dy = abs(clearLocation.y - lastHittedLocation.y)
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
        }
    }

    func performEnemyRandomFire() {
        let clearLocations = findAllClearLocations()
        guard var location = clearLocations.randomElement() else { return }

        if let suggestedLocation = self.suggestedLocation {
            location = suggestedLocation
            self.suggestedLocation = nil
        } else if let lastHittedLocation = self.lastHittedLocation {
            let nearestLocations = getNearestLocations(to: lastHittedLocation, from: clearLocations)
            if let directionToLastHit = self.directionToLastHit {
                let calculatedLocation = lastHittedLocation.move(in: directionToLastHit, within: self)
                location = (clearLocations.contains(calculatedLocation) ? calculatedLocation : self.suggestLocation(available: clearLocations))!
            } else if let foundLocation = nearestLocations.randomElement() {
                location = foundLocation
            }
        }

        let hitStatus = self.playerZoneTapped(location)

        // filter last location
        let stillAvailableClearLocations = clearLocations.filter { tempLocation in
            return tempLocation != location
        }

        if hitStatus == .miss {
            self.suggestedLocation = suggestLocation(available: stillAvailableClearLocations)
        } else if hitStatus == .hit {
            if let lastHittedLocation = self.lastHittedLocation {
                self.directionToLastHit = lastHittedLocation.compare(location)
            }
             
            self.lastHittedLocation = location
            self.suggestedLocation = nil
        } else if hitStatus == .sunk {
            self.lastHittedLocation = nil
            self.directionToLastHit = nil
            self.suggestedLocation = nil
        }
    }

    func suggestLocation(available stillAvailableClearLocations: [Coordinate]) -> Coordinate? {

        guard let lastHittedLocation = self.lastHittedLocation,
            let directionToLastHit = self.directionToLastHit else {
            return nil
        }

        let x = lastHittedLocation.x
        let y = lastHittedLocation.y

        let filteredLocations: [Coordinate]
        let sortedLocations: [Coordinate]

        switch directionToLastHit {
        case .top:
            filteredLocations = stillAvailableClearLocations.filter { $0.x == x && $0.y > y }
            sortedLocations = filteredLocations.sorted { $0.y < $1.y }
        case .bottom:
            filteredLocations = stillAvailableClearLocations.filter { $0.x == x && $0.y < y }
            sortedLocations = filteredLocations.sorted { $0.y > $1.y }
        case .right:
            filteredLocations = stillAvailableClearLocations.filter { $0.y == y && $0.x < x }
            sortedLocations = filteredLocations.sorted { $0.x > $1.x }
        case .left:
            filteredLocations = stillAvailableClearLocations.filter { $0.y == y && $0.x > x }
            sortedLocations = filteredLocations.sorted { $0.x < $1.x }
        default:
            return nil
        }
        return sortedLocations.first

    }

    func findAllClearLocations() -> [Coordinate] {
        var locations = [Coordinate]()
        for (x, states) in self.playerZoneStates.enumerated() {
            for (y, state) in states.enumerated() {
                if case .clear = state {
                    let location = Coordinate(x: x, y: y)
                    locations.append(location)
                }
            }
        }
        return locations
    }
}
