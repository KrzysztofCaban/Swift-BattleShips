// Enum Direction reprezentuje możliwe kierunki przesunięcia
enum Direction {
    // Reprezentuje brak przesunięcia (obie współrzędne są równe)
    case equal

    // Reprezentuje przesunięcie do góry
    case top 

    // Reprezentuje przesunięcie w prawo
    case right 

    // Reprezentuje przesunięcie w dół
    case bottom 

    // Reprezentuje przesunięcie w lewo
    case left 

    // Reprezentuje nieprawidłowe przesunięcie (np. próba przesunięcia poza granice planszy)
    case invalid 
}
