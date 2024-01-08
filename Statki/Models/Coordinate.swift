import Foundation

struct Coordinate: Hashable {
    // Koordynaty punktu
    var x: Int = 0
    var y: Int = 0
    // Statyczna zmienna reprezentująca punkt (0,0)
    static var zero = Coordinate(x: 0, y: 0)
    
    // Definicja operatora porównania dwóch punktów
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    // Funkcja porównująca dwie współrzędne
    func compare(_ other: Coordinate) -> Direction {
        // Sprawdzamy różnicę współrzędnych
        switch (self.x - other.x, self.y - other.y) {

        //  Jeżeli różnica jest równa 0 to zwracamy .equal
        case (0, 0):
            return .equal

        case (let deltaX, 0):
            if deltaX >= 0 {
                // Jeżeli deltaX jest większe od 0 to zwracamy .left
                return .left
            } else {
                // W przeciwnym wypadku zwracamy .right
                return .right
            }

        // Jeżeli różnica jest równa 1 to zwracamy odpowiednią wartość
        case (0, let deltaY):
            if deltaY >= 0 {
                // Jeżeli deltaY jest większe od 0 to zwracamy .top
                return .top
            } else {
                // W przeciwnym wypadku zwracamy .bottom
                return .bottom
            }

        default:
            // Jeśli zarówno x, jak i y są różne, zwracamy .invalid
            return .invalid
        }
    }
    
    // Funkcja przesuwająca współrzędne w danym kierunku
    func move(in direction: Direction, within game: Game) -> Coordinate {

        // Tworzymy kopię obecnej współrzędnej
        var newCoordinate = self

        // Wybieramy kierunek przesunięcia
        switch direction {

        // Jeżeli współrzędna y jest większa od 0, przesuwamy ją o 1 w górę
        case .top:
            if newCoordinate.y > 0 {
                newCoordinate.y -= 1
            }

        // Jeżeli współrzędna y jest mniejsza od liczby wierszy gry minus 1, przesuwamy ją o 1 w dół
        case .bottom:
            if newCoordinate.y < game.numRows - 1 {
                newCoordinate.y += 1
            }

        // Jeżeli współrzędna x jest większa od 0, przesuwamy ją o 1 w lewo
        case .left:
            if newCoordinate.x > 0 {
                newCoordinate.x -= 1
            }

        // Jeżeli współrzędna x jest mniejsza od liczby kolumn gry minus 1, przesuwamy ją o 1 w prawo
        case .right:
            if newCoordinate.x < game.numCols - 1 {
                newCoordinate.x += 1
            }

        // W przypadku nieznanych kierunków, nie robimy nic
        default:
            break
        }

        // Zwracamy nową współrzędną
        return newCoordinate
    }
}

extension Coordinate: CustomStringConvertible {
    var description: String {
            return "(\(x), \(y))"
        }
}
