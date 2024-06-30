import Chroma
import ChromaShell
import Foundation
// Using Swift NIO as it has better async file API's right now. This should all 
// get replaced by Swift SubProcess.
import NIOCore
import _NIOFileSystem

@main
struct ShellExample: ChromaShell {
    var main: some Block {
        // Creates a new process and writes the output to test.txt in the
        // current working directory
        ShellCommand("echo hello",output: .file("test.txt"))
    }
}

struct ShellCommand: Block {

    // Keep track of the high level state of the command
    enum ShellState {
        case waiting
        case running
        case finished
    }

    @State var state: ShellState
    let cmd: String
    let output: Output

    init(_ cmd: String, output: Output) {
        self.state = .waiting
        self.cmd = cmd
        self.output = output
    }

    var component: some Block {
        Button("Shell[\(self.state)]: \(self.cmd) ") {
            self.state = .running
            Task {
                try await shell(cmd, output: output)
                self.state = .finished
            }
        }
    }
}

func shell(_ command: String, output: Output) async throws {
    try await runProcess(
        binary: "/bin/zsh",
        arguments: ["-c", command],
        outputFile: output)
}

enum Output {
    case file(FilePath)
    case null
}

func runProcess(binary path: String, arguments: [String], outputFile: Output)
    async throws
{
    let binFile = "file://\(path)"
    guard let url = URL(string: binFile) else {
        throw ProcessError.invalidPath(binFile)
    }

    let process = Process()
    let pipe = Pipe()
    process.executableURL = url
    process.arguments = arguments

    var out: FilePath? = nil

    switch outputFile {
    case let .file(path):
        out = path
        process.standardError = pipe
        process.standardOutput = pipe
    case .null:
        out = nil
        process.standardError = nil
        process.standardOutput = nil
    }

    try process.run()

    if let out {
        let data = try pipe.fileHandleForReading.readToEnd()!
        if let output = String(data: data, encoding: .utf8) {
            let fileSystem = FileSystem.shared
            // get folder path
            let folder = out.removingLastComponent()
            // created directories as needed
            try? await fileSystem.createDirectory(
                at: folder, withIntermediateDirectories: true)
            // open/create file
            let fh = try await fileSystem.openFile(
                forReadingAndWritingAt: out,
                options: .modifyFile(createIfNecessary: true))
            var writer = fh.bufferedWriter()
            try await writer.write(contentsOf: ByteBuffer(string: output))
            try await writer.flush()
            try await fh.close()
        }
    }
    process.waitUntilExit()
}

enum ProcessError: Error {
    case invalidPath(String)
}
