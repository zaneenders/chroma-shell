import Chroma
import Foundation

/// A protocol to start using blocks to describe your terminal experience
public protocol ChromaShell {
    associatedtype Component: Block
    @BlockParser var main: Component { get }
    init()
}

extension ChromaShell {
    public static func main() async {
        let runtime = InteractionLoop(self.init().main)
        await runtime.start()
    }
}
