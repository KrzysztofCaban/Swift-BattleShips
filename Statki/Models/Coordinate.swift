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

    // Definiujemy typ wyliczeniowy do porównywania dwóch współrzędnych
    enum ComparsionVector {
        case equal
        case top
        case right
        case bottom
        case left
        case invalid
    }

    // Funkcja porównująca dwie współrzędne
    func compare(_ other: Coordinate) -> ComparsionVector {
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
}

extension Coordinate: CustomStringConvertible {
    var description: String {
            return "(\(x), \(y))"
        }
}
