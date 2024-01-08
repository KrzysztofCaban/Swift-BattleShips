import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var game: Game
    
    var body: some View {
        HStack {
            Button(action:{
                withAnimation {
                    reset()
                }}) {Image(systemName: "repeat")}
                .help("Start a new game.")
                .foregroundColor(.accentColor)
                .padding(.leading, 10)
            Spacer()
            Text(game.message)
            Spacer()
            Text("\(game.turnCounter)")
                .padding(.trailing, 10)



        }.frame(height: 30)
    }
    
    func reset() {
        game.reset()
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
            .environmentObject(Game(numCols: 8, numRows: 8))
    }
}

