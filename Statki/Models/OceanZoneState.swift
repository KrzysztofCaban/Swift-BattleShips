import Foundation

// Definiujemy typ wyliczeniowy (enum) o nazwie OceanZoneState. 
// Ten typ wyliczeniowy reprezentuje różne stany, które może przyjąć strefa oceanu w kontekście gry w statki.
enum OceanZoneState {
    // Stan "clear" oznacza, że w strefie nie został wykonany strzał. 
    // Może zawierać statek (Ship?), ale nie musi - stąd opcjonalny typ Ship.
    case clear(Ship?)
    // Stan "miss" oznacza, że w tej strefie wykonano strzał, ale nie trafił on w żaden statek.
    case miss
    // Stan "hit" oznacza, że w tej strefie wykonano strzał, który trafił w statek.
    case hit
}
