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
                gameMessage = "You missed"
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
                    gameMessage = "Enemy did sunk your \(hitShip.name)!"
                    status = .sunk

                    self.lastHittedLocation = nil
                    self.directionToLastHit = nil
                    self.suggestedLocation = nil
                } else {
                    gameMessage = "Hited at x:\(location.x), y:\(location.y)"
                    status = .hit
                }
            } else {
                playerZoneStates[location.x][location.y] = .miss
                gameMessage = "Missed at x:\(location.x), y:\(location.y)"
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

    func performEnemyRandomFire() {
        let clearLocations = findAllClearLocations()
        guard var location = clearLocations.randomElement() else { return }

        if let suggestedLocation = self.suggestedLocation {
            location = suggestedLocation
            self.suggestedLocation = nil
        } else if let lastHittedLocation = self.lastHittedLocation {
            
            var nearestLocations = [Coordinate]()
            for clearLocation in clearLocations {
                let x = clearLocation.x
                let y = clearLocation.y
                
                if (lastHittedLocation.y == y + 1 && lastHittedLocation.x == x) // up
                    || (lastHittedLocation.y == y - 1 && lastHittedLocation.x == x) // down
                    || (lastHittedLocation.x == x - 1 && lastHittedLocation.y == y) // left
                    || (lastHittedLocation.x == x + 1 && lastHittedLocation.y == y) { // right
                    nearestLocations.append(clearLocation)
                }
            }
            if let directionToLastHit = self.directionToLastHit {
                let calculatedLocation = lastHittedLocation.move(in: directionToLastHit, within: self)
                if clearLocations.contains(calculatedLocation) {
                    location = calculatedLocation
                } else if let suggestedLocation = self.suggestLocation(available: clearLocations) {
                    location = suggestedLocation
                }
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
        if let lastHittedLocation = self.lastHittedLocation {
            let x = lastHittedLocation.x
            let y = lastHittedLocation.y

            if let directionToLastHit = self.directionToLastHit {
                switch directionToLastHit {
                case .top:
                    let locationsForTop = stillAvailableClearLocations.filter { location in
                        return location.x == x && location.y > y
                    }
                    if let nearestLocationForTop = locationsForTop.sorted(by: { location1, location2 in
                        return location1.y < location2.y
                    }).first {
                        return nearestLocationForTop
                    }
                case .bottom:
                    let locationsForBottom = stillAvailableClearLocations.filter { location in
                        return location.x == x && location.y < y
                    }
                    if let nearestLocationForBottom = locationsForBottom.sorted(by: { location1, location2 in
                        return location1.y > location2.y
                    }).first {
                        return nearestLocationForBottom
                    }
                case .right:
                    let locationsForLeft = stillAvailableClearLocations.filter { location in
                        return location.y == y && location.x < x
                    }
                    if let nearestLocationForLeft = locationsForLeft.sorted(by: { location1 , location2 in
                        return location1.x > location2.x
                    }).first {
                        return nearestLocationForLeft

                    }
                case .left:
                    let locationsForRight = stillAvailableClearLocations.filter { location in
                        return location.y == y && location.x < x
                    }
                    if let nearestLocationForRight = locationsForRight.sorted(by: { location1, location2 in
                        return location1.x < location2.x
                    }).first {
                        return nearestLocationForRight
                    }
                default:
                    break
                }
            }
        }
        return nil
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
