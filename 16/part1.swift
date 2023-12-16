import Foundation

let NORTH = 1

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

