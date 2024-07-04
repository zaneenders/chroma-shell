import Foundation
import ScribeCore

/// A protocol to start using blocks to describe your terminal experience
public protocol ChromaShell {
    associatedtype Component: Block
    @BlockParser var main: Component { get }
    init()
}

extension ChromaShell {
    public static func main() async {
        let block = self.init().main
        await start(block)
    }

    private static func start(_ block: some Block) async {
        let terminal = Terminal()
        let scribe = await Scribe(
            observing: block, width: terminal.size.x, height: terminal.size.y,
            draw(_:_:_:))
        let standardInput = Process().standardInput
        let fileHandleForStandardIn = standardInput as! FileHandle

        // Draw the first frame
        let frame = await scribe.current
        draw(frame, terminal.size.x, terminal.size.y)
        do {
            for try await byte in fileHandleForStandardIn.asyncByteIterator() {
                // update on input
                guard let code = AsciiKeyCode.decode(keyboard: byte) else {
                    continue
                }

                // Update size for next frame
                await scribe.updateSize(
                    width: terminal.size.x, height: terminal.size.y)

                switch await scribe.mode {
                case .input:
                    switch code {
                    case .ctrlC:
                        await scribe.command(.out)
                    default:
                        // TODO space not working
                        if let input = String(bytes: [byte], encoding: .utf8) {
                            await scribe.command(.unsafeInput(input))
                        }
                    }
                case .normal:
                    switch code {
                    case .ctrlC:
                        return
                    case .lowerCaseL:
                        await scribe.command(.in)
                    case .lowerCaseS:
                        await scribe.command(.out)
                    case .lowerCaseJ:
                        await scribe.command(.down)
                    case .lowerCaseF:
                        await scribe.command(.up)
                    case .lowerCaseK:
                        await scribe.command(.right)
                    case .lowerCaseD:
                        await scribe.command(.left)
                    default:
                        ()
                    }
                }
            }
        } catch let error {
            // Lets keep all errors internal as we are changing the default behavior of the Terminal
            // TODO logging
            print(error.localizedDescription)
            return
        }
    }
}


func draw(_ visible: VisibleNode, _ x: Int, _ y: Int) {
    let ascii = visible.drawVisible(x, y).0
    ChromaFrame(ascii, .default, .default).render()
}
