import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var game: Game
    
    private var resetButton: some View {
        Button(action:{
            withAnimation {
                game.reset()
            }
        }) {Image(systemName: "repeat")}
            .help("Start a new game.")
            .foregroundColor(.accentColor)
            .padding(.leading, 10)
    }
    
    var body: some View {
        HStack {
            resetButton
            Spacer()
            Text(game.gameMessage)
            Spacer()
            Text("\(game.turnCounter)")
                .padding(.trailing, 10)
        }.frame(height: 30)
    }
}
