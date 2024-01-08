// Enum ShipHitStatus reprezentuje możliwe statusy po strzale do statku
enum ShipHitStatus {

    // Reprezentuje sytuację, gdy strzał nie trafił w żaden statek
    case miss

    // Reprezentuje sytuację, gdy strzał trafił w statek, ale nie zatopił go całkowicie
    case hit

    // Reprezentuje sytuację, gdy strzał zatopił statek całkowicie
    case sunk

    // Reprezentuje sytuację, gdy gra się skończyła (wszystkie statki zostały zatopione)
    case over
}
