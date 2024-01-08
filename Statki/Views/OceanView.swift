import SwiftUI

// Widok planszy
struct OceanView: View {

    // Referencja do obiektu Game, który jest dostępny w całej aplikacji
    @EnvironmentObject var game: Game

    // Zmienna przechowująca informację o tym, czy plansza należy do gracza, czy przeciwnika
    let ownership: Ownership
    var body: some View {
        let range = (0..<(game.numCols * game.numRows))
        let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 0), count: game.numCols)
        GeometryReader { geo in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(range, id: \.self) {index in
                    let y = index / game.numRows
                    let x = index - (y * game.numCols)
                    let location = Coordinate(x: x, y: y)
                    switch self.ownership {
                    case .player:
                        OceanZoneView(state: $game.playerZoneStates[x][y], forceVisibility: true)
                            .frame(height: geo.size.height/CGFloat(game.numRows))

                    case .enemy:
                        OceanZoneView(state: $game.enemyZoneStates[x][y], forceVisibility: false)
                            .frame(height: geo.size.height/CGFloat(game.numRows))
                            .onTapGesture {
                                _ = game.enemyZoneTapped(location)
                            }
                    }
                }
            }
        }
    }
}
