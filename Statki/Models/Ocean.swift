import Foundation

struct Ocean {
    // Zmienne przechowujące liczbę kolumn i wierszy
    var numCols: Int
    var numRows: Int
    // Prywatna zmienna przechowująca punkt początkowy (0,0)
    private var origin: Coordinate = .zero
    
    // Inicjalizator struktury Ocean
    init(numCols: Int, numRows: Int) {
        self.numCols = numCols
        self.numRows = numRows
    }
    
     // Funkcja sprawdzająca, czy ocean zawiera dany punkt
    func contains(_ point: Coordinate) ->Bool
    {
        // Zwraca prawdę, jeśli punkt znajduje się w granicach oceanu
        return (point.x >= origin.x && point.y >= origin.y && point.x < numCols && point.y < numRows)
    }
    
    // Funkcja sprawdzająca, czy ocean zawiera wszystkie podane punkty
    func contains(_ points: Array<Coordinate>) ->Bool
    {
        // Zwraca prawdę, jeśli żaden z punktów nie znajduje się poza granicami oceanu
        return !points.contains(where:{!self.contains($0)})
    }
    
    // Funkcja zwracająca lokalizacje, które pozwalają na umieszczenie statku o podanej długości
    func locationsThatFit(length: Int) -> [[Coordinate]] {
        // Inicjalizacja tablicy przechowującej możliwe lokalizacje statków
        var locations = [[Coordinate]]()
        
        // Sprawdzenie dopasowań statku w poziomie
        for y in 0..<numRows {
            for start in 0...(numCols - length) {
                var span = [Coordinate]()
                for x in start..<(start + length) {
                    // Dodanie współrzędnych do tablicy
                    span.append(Coordinate(x: x, y: y))
                }
                // Dodanie tablicy współrzędnych do tablicy możliwych lokalizacji
                locations.append(span)
            }
        }
        
        // Sprawdzenie dopasowań statku w pionie
        for x in 0..<numCols {
            for start in 0...(numRows - length) {
                var span = [Coordinate]()
                for y in start..<(start + length) {
                    // Dodanie współrzędnych do tablicy
                    span.append(Coordinate(x:x, y:y))
                }
                // Dodanie tablicy współrzędnych do tablicy możliwych lokalizacji
                locations.append(span)
            }
        }
        // Zwrócenie tablicy możliwych lokalizacji
        return locations
    }
}
