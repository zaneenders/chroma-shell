import ChromaShell
import Foundation
import Observation
import ScribeCore
import _NIOFileSystem

@Observable
final class FileSystemManager {
    var cwd: String
    var names: [String] = ["Zane"]
    init() {
        self.cwd = FileManager.default.currentDirectoryPath
    }

    func update() {
        Task(priority: .userInitiated) {
            self.names = await getFileNames(at: FilePath(cwd))
        }
    }
}

struct FileSystemBlock: Block {
    init() {}
    let fileSystem = FileSystemManager()
    var component: some Block {
        Button("\(fileSystem.cwd)") {
            fileSystem.update()
        }
        for name in fileSystem.names {
            "\(name)"
        }
    }
}

@main
struct FileSystemMain: ChromaShell {
    var main: some Block {
        // FileSystemBlock()
        "Hello Zane"
    }
}

func getFileNames(at path: FilePath) async -> [String] {
    var names: [String] = []
    let fileSystem: FileSystem = FileSystem.shared
    do {
        try await fileSystem.withDirectoryHandle(atPath: path, options: .init())
        { dir in
            for try await file in dir.listContents() {
                names.append("\(file.name)")
            }
        }
    } catch let error {
        // TODO log error
        return []
    }
    return names
}
