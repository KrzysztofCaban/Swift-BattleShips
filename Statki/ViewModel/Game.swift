import Foundation

final class Game: ObservableObject {
    
    // Liczba kolumn na planszy gry
    let numCols: Int

    // Liczba wierszy na planszy gry
    let numRows: Int

    // Ocean gracza
    var playerOcean: Ocean

     // Ocean przeciwnika
    var enemyOcean: Ocean

    // Flota gracza
    var playerFleet: Fleet

    // Flota przeciwnika
    var enemyFleet: Fleet

    // Stan strefy oceanu gracza
    @Published var playerZoneStates = [[OceanZoneState]]()

    // Stan strefy oceanu przeciwnika
    @Published var enemyZoneStates = [[OceanZoneState]]()

    // Wiadomość wyświetlana w grze
    @Published var gameMessage = ""

    // Licznik tur
    @Published var turnCounter: Int = 0

    // Właściwość sprawdzająca, czy gra jest zakończona
    var over: Bool {
        return playerFleet.isDestroyed() || enemyFleet.isDestroyed()
    }
    
    // Ostatnia lokalizacja, w którą trafił przeciwnik
    var lastHittedLocation: Coordinate?

    // Sugerowana lokalizacja dla następnego strzału
    var suggestedLocation: Coordinate?

    // Kierunek do ostatniego trafienia
    var directionToLastHit: Direction?
    
    // Inicjalizator klasy Game
    init(numCols: Int, numRows: Int) {
        self.numRows = numRows
        self.numCols = numCols
        self.playerOcean = Ocean(numCols: numCols, numRows: numRows)
        self.playerFleet = Fleet()
        self.enemyOcean = Ocean(numCols: numCols, numRows: numRows)
        self.enemyFleet = Fleet()
        reset()
    }
    
    // Funkcja resetująca grę
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
    
    
    // Funkcja obsługująca tapnięcie w strefę przeciwnika
    func enemyZoneTapped(_ location: Coordinate) -> ShipHitStatus {

        // Sprawdzamy, czy gra jest zakończona
        // Jeżeli tak, to wyświetlamy odpowiedni komunikat i zwracamy status .over
        guard !over else {
            gameMessage = "YOU LOST !"
            return .over
        }

        // Domyślny status strzału to pudło
        var status: ShipHitStatus = .miss

        // Sprawdzamy, czy strefa, w którą tapnięto, jest wolna
        if case .clear = enemyZoneStates[location.x][location.y] {

            // Inkrementujemy licznik tur
            self.turnCounter += 1

            // Sprawdzamy, czy w lokalizacji tapnięcia jest statek przeciwnika
            if let hitShip = enemyFleet.ship(at: location) {

                // Jeśli tak, to zaznaczamy trafienie w tym statku
                hitShip.hit(at: location)

                // Zmieniamy stan strefy na trafiony
                enemyZoneStates[location.x][location.y] = .hit

                // Sprawdzamy, czy statek został zatopiony
                if hitShip.isSunk() {

                    // Jeśli tak, to wyświetlamy odpowiednią wiadomość
                    gameMessage = "You sunk enemy \(hitShip.name)!"

                    // Zmieniamy status strzału na zatopiony
                    status = .sunk
                } else {

                    // Jeśli nie, to wyświetlamy wiadomość o trafieniu
                    gameMessage = "Your hit at x:\(location.x), y:\(location.y)"

                    // Zmieniamy status strzału na trafiony
                    status = .hit
                }
            } else {

                // Jeśli nie ma statku, to zmieniamy stan strefy na pudło
                enemyZoneStates[location.x][location.y] = .miss

                // Wyświetlamy wiadomość o pudle
                gameMessage = "You missed at x:\(location.x), y:\(location.y)"
            }

            // Wywołujemy akcję przeciwnika wywołaną po 0.7 sekundy
            Task {
                let duration = UInt64(0.7 * 1_000_000_000) // nanoseconds
                await self.delayedAction(for: duration)
            }
        }

        // Zwracamy status strzału
        return status
    }

    // Funkcja obsługująca tapnięcie w strefę gracza
    func playerZoneTapped(_ location: Coordinate) -> ShipHitStatus {

        // Sprawdzamy, czy gra jest zakończona
        guard !over else {
            gameMessage = "YOU WON !"
            return .over
        }

        // Domyślny status strzału to pudło
        var status: ShipHitStatus = .miss

        // Sprawdzamy, czy strefa, w którą tapnięto, jest wolna
        if case .clear = playerZoneStates[location.x][location.y] {

            // Sprawdzamy, czy w lokalizacji tapnięcia jest statek gracza
            if let hitShip = playerFleet.ship(at: location) {

                // Jeśli tak, to zaznaczamy trafienie w tym statku
                hitShip.hit(at: location)

                // Zmieniamy stan strefy na trafiony
                playerZoneStates[location.x][location.y] = .hit

                // Sprawdzamy, czy statek został zatopiony
                if hitShip.isSunk() {
                    // Jeśli tak, to wyświetlamy odpowiednią wiadomość
                    gameMessage = "Enemy sunk your \(hitShip.name)!"

                    // Zmieniamy status strzału na zatopiony
                    status = .sunk

                    // Resetujemy ostatnią trafioną lokalizację, kierunek do ostatniego trafienia i sugerowaną lokalizację
                    self.lastHittedLocation = nil
                    self.directionToLastHit = nil
                    self.suggestedLocation = nil
                } else {

                    // Jeśli nie, to wyświetlamy wiadomość o trafieniu
                    gameMessage = "Enemy hited at x:\(location.x), y:\(location.y)"

                    // Zmieniamy status strzału na trafiony
                    status = .hit
                }
            } else {

                // Jeśli nie ma statku, to zmieniamy stan strefy na pudło
                playerZoneStates[location.x][location.y] = .miss

                // Wyświetlamy wiadomość o pudle
                gameMessage = "Enemy miss at x:\(location.x), y:\(location.y)"
            }
        }

        // Zwracamy status strzału
        return status
    }

    // Tworzymy dwuwymiarową tablicę ze wszystkimi strefami ustawionymi na .clear
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

    // Funkcja wykonująca opóźnioną akcję przeciwnika
    func delayedAction(for nanoseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: nanoseconds)
        await MainActor.run {
            self.performEnemyRandomFire()
        }
    }

    // Zwracamy najbliższe lokalizacje do ostatniej trafionej lokalizacji
    func getNearestLocations(to lastHittedLocation: Coordinate, from clearLocations: [Coordinate]) -> [Coordinate] {
        clearLocations.filter { clearLocation in
            let dx = abs(clearLocation.x - lastHittedLocation.x)
            let dy = abs(clearLocation.y - lastHittedLocation.y)
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
        }
    }

    // Funkcja wykonująca losowy strzał przeciwnika
    func performEnemyRandomFire() {

        // Znajdujemy wszystkie wolne lokalizacje
        let clearLocations = findAllClearLocations()

        // Wybieramy losową lokalizację z wolnych
        guard var location = clearLocations.randomElement() else { return }

        // Jeśli mamy sugerowaną lokalizację, to ją wybieramy
        if let suggestedLocation = self.suggestedLocation {
            location = suggestedLocation
            self.suggestedLocation = nil
        } else if let lastHittedLocation = self.lastHittedLocation {

            // Jeśli mamy ostatnią trafioną lokalizację, to szukamy najbliższych do niej
            let nearestLocations = getNearestLocations(to: lastHittedLocation, from: clearLocations)
            if let directionToLastHit = self.directionToLastHit {

                // Jeśli mamy kierunek do ostatniego trafienia, to obliczamy nową lokalizację
                let calculatedLocation = lastHittedLocation.move(in: directionToLastHit, within: self)
                if clearLocations.contains(calculatedLocation) {

                    // Jeśli obliczona lokalizacja jest wolna, to ją wybieramy
                    location = calculatedLocation
                } else {

                    // Jeśli nie, to sugerujemy nową lokalizację
                    if let suggestedLocation = self.suggestLocation(available: clearLocations) {
                        location = suggestedLocation
                    }
                }

            } else if let foundLocation = nearestLocations.randomElement() {

                // Jeśli nie mamy kierunku do ostatniego trafienia, to wybieram lokalizację z najbliższych
                location = foundLocation
            }
        }

        // Wykonujemy strzał w wybraną lokalizację
        let hitStatus = self.playerZoneTapped(location)

        // Filtrujemy dostępne lokalizacje, usuwając tę, w którą strzeliliśmy
        let stillAvailableClearLocations = clearLocations.filter { tempLocation in
            return tempLocation != location
        }

        // W zależności od wyniku strzału, podejmujemy różne działania
        if hitStatus == .miss {

            // Jeśli strzał nie trafił, sugerujemy nową lokalizację
            self.suggestedLocation = suggestLocation(available: stillAvailableClearLocations)

        } else if hitStatus == .hit {

            // Jeśli strzał trafił, zapisujemy kierunek do ostatniego trafienia i lokalizację trafienia
            if let lastHittedLocation = self.lastHittedLocation {
                self.directionToLastHit = lastHittedLocation.compare(location)
            }
            self.lastHittedLocation = location
            self.suggestedLocation = nil
        } else if hitStatus == .sunk {

            // Jeśli strzał zatopił statek, resetujemy ostatnią lokalizację trafienia, kierunek do ostatniego trafienia i sugerowaną lokalizację
            self.lastHittedLocation = nil
            self.directionToLastHit = nil
            self.suggestedLocation = nil
        }
    }

    // Funkcja sugerująca nową lokalizację do strzału
    func suggestLocation(available stillAvailableClearLocations: [Coordinate]) -> Coordinate? {

        // Jeśli nie mamy ostatniej lokalizacji trafienia lub kierunku do ostatniego trafienia, zwracamy nil
        guard let lastHittedLocation = self.lastHittedLocation,
            let directionToLastHit = self.directionToLastHit else {
            return nil
        }

        let x = lastHittedLocation.x
        let y = lastHittedLocation.y

        let filteredLocations: [Coordinate]
        let sortedLocations: [Coordinate]

        // W zależności od kierunku do ostatniego trafienia, filtrujemy i sortujemy lokalizacje
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

    // Funkcja znajdująca wszystkie wolne lokalizacje
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
