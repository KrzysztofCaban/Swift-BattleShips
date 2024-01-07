import Foundation

struct Ocean {
    var numCols: Int
    var numRows: Int
    private var origin: Coordinate = .zero
    
    init(numCols: Int, numRows: Int) {
        self.numCols = numCols
        self.numRows = numRows
    }
    
    //CHECK IF OCEAN CONTAINS THE COORDINATE POINT
    func contains(_ point: Coordinate) ->Bool
    {
        return (point.x >= origin.x && point.y >= origin.y && point.x < numCols && point.y < numRows)
    }
    
    //CHECK IF OCEAN CONTAINS ALL THE GIVEN COORDINATES
    func contains(_ points: Array<Coordinate>) ->Bool
    {
        return !points.contains(where:{!self.contains($0)})
    }
    
    //RETURN LOCATIONS THAT FIT WITH SHIP WITH GIVEN LENGTH
    func locationsThatFit(length: Int) -> [[Coordinate]] {
        var locations = [[Coordinate]]()
        
        //HORIZONTAL FITS
        for y in 0..<numRows {
            for start in 0...(numCols - length) {
                var span = [Coordinate]()
                for x in start..<(start + length) {
                    span.append(Coordinate(x: x, y: y))
                }
                locations.append(span)
            }
        }
        
        //VERTICAL FITS
        for x in 0..<numCols {
            for start in 0...(numRows - length) {
                var span = [Coordinate]()
                for y in start..<(start + length) {
                    span.append(Coordinate(x:x, y:y))
                }
                locations.append(span)
            }
        }
        return locations
    }
}
