import Foundation

typealias Direction = UInt8
struct Loc {
    var x: Int
    var y: Int
}
struct State {
    var loc: Loc
    var dir: Direction
}

let NORTH: Direction = 1
let EAST: Direction = 2
let SOUTH: Direction = 4
let WEST: Direction = 8

// ascii(7)
let EMPTY: UInt8 = 46
let DOWN_MIRROR: UInt8 = 92
let UP_MIRROR: UInt8 = 47
let HORIZ_SPLIT: UInt8 = 45
let VERT_SPLIT: UInt8 = 124

var queue = [State]()
var input = [[UInt8]]()
var visited = [[UInt8]]()
var width = 0
var height = 0

func reset() {
    queue = [State]()
    visited = [[UInt8]]()
    for _ in 0...height-1 {
        visited.append(Array(repeating: 0, count: width));
    }
}

func newDirection(fromState: State, gridSquare: UInt8) -> Direction {
    //print("newDirection(\(fromState), \(gridSquare)")
    switch gridSquare {
        case EMPTY: return fromState.dir
        case DOWN_MIRROR: return switch fromState.dir {
            case NORTH: WEST
            case EAST:  SOUTH
            case SOUTH: EAST
            case WEST:  NORTH
            default: 0
        }
        case UP_MIRROR: return switch fromState.dir {
            case NORTH:   EAST
            case EAST:    NORTH
            case SOUTH:   WEST
            case WEST:    SOUTH
            default: 0
        }
        case HORIZ_SPLIT: switch fromState.dir {
            case WEST, EAST: return fromState.dir
            default:
                queue.append(State(loc:Loc(x: fromState.loc.x, y: fromState.loc.y), dir:EAST))
                return WEST
        }
        case VERT_SPLIT: switch fromState.dir {
            case NORTH, SOUTH: return fromState.dir
            default:
                queue.append(State(loc:Loc(x: fromState.loc.x, y: fromState.loc.y), dir:NORTH))
                return SOUTH
        }
        default: return 0
    }
}

func step(fromState: State) -> Optional<State> {
    var nst = State(loc:Loc(x:fromState.loc.x, y:fromState.loc.y), dir:0)
    let ch = input[fromState.loc.y][fromState.loc.x]
    nst.dir = newDirection(fromState: fromState, gridSquare: ch)

    switch nst.dir {
        case NORTH:
            if fromState.loc.y == 0 {
                return Optional.none
            }
            nst.loc.y -= 1
        case EAST:
            if fromState.loc.x == width-1 {
                return Optional.none
            }
            nst.loc.x = nst.loc.x + 1
        case SOUTH:
            if fromState.loc.y == height-1 {
                return Optional.none
            }
            nst.loc.y += 1
        case WEST:
            if fromState.loc.x == 0 {
                return Optional.none
            }
            nst.loc.x -= 1
        default:
            return Optional.none
    }

    return Optional.some(nst)
}

while let str = readLine(strippingNewline: true) {
    if width == 0 {
        width = str.count
    }
    input.append(Array(str.utf8))
}
height = input.count

func total(startingFrom: State) -> Int {
    reset()
    queue.append(startingFrom)

    while queue.count > 0 {
        let st0 = queue.removeFirst()
        /*
        print("st0=\(st0)")
        print("visited[\(st0.loc.y)][\(st0.loc.x)] = \(visited[st0.loc.y][st0.loc.x])")
        if 0 != (visited[st0.loc.y][st0.loc.x] & st0.dir) {
            continue
        }
        */
        var nst = Optional.some(st0)
        while let st = nst {
            /*
            print("queue=\(queue)")
            print("st=\(st)")
            print("visited[\(st.loc.y)][\(st.loc.x)] = \(visited[st.loc.y][st.loc.x])")
            print("input[\(st.loc.y)][\(st.loc.x)] = \(input[st.loc.y][st.loc.x])")
            */
            if 0 != visited[st.loc.y][st.loc.x] & st.dir {
                break
            }
            visited[st.loc.y][st.loc.x] |= st.dir
            nst = step(fromState: st)
        }
    }

    var tot = 0
    for i in 0...height-1 {
        for j in 0...width-1 {
            if visited[i][j] != 0 {
                tot += 1
            }
        }
    }

    return tot
}

var max = 0
for y in 0...height-1 {
    let totLeft = total(startingFrom: State(loc: Loc(x: 0, y: y), dir: EAST))
    if totLeft > max {
        max = totLeft
    }
    let totRight = total(startingFrom: State(loc: Loc(x: width-1, y: y), dir:WEST))
    if totRight > max {
        max = totRight
    }
}
for x in 0...width-1 {
    let totTop = total(startingFrom: State(loc: Loc(x: x, y: 0), dir: SOUTH))
    if totTop > max {
        max = totTop
    }
    let totBot = total(startingFrom: State(loc: Loc(x: x, y: height-1), dir: NORTH))
    if totBot > max {
        max = totBot
    }
}

print(max)


/*
var args: [String] = []
if (CommandLine.arguments.count == 1) {
    args.append("-")
} else {
    args.append(contentsOf: CommandLine.arguments[1...])
}

func copyBytes(fromHandle: FileHandle) throws {
    while let contents = try fromHandle.read(upToCount: 4096) {
        try FileHandle.standardOutput.write(contentsOf: contents)
    }
}

for arg in args {
    if "-" == arg {
        try copyBytes(fromHandle: FileHandle.standardInput)
    } else {
        if let h = FileHandle.init(forReadingAtPath: arg) {
            try copyBytes(fromHandle: h)
            try h.close()
        }
    }
}

*/
