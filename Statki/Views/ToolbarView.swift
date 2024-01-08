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

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
            .environmentObject(Game(numCols: 8, numRows: 8))
    }
}

