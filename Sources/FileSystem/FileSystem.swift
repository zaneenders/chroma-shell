import ChromaShell
import Foundation
import Observation
import ScribeCore

@Observable
final class FileSystemManager {
    var cwd: String
    init() {
        self.cwd = FileManager.default.currentDirectoryPath
    }
}

struct FileSystemBlock: Block {
    init() {}
    let fileSystem = FileSystemManager()
    var component: some Block {
        "\(fileSystem.cwd)"
    }
}

@main
struct FileSystem: ChromaShell {
    var main: some Block {
        // Creates a new process and writes the output to test.txt in the
        // current working directory
        FileSystemBlock()
    }
}
