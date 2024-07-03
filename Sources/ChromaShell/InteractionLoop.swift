import Foundation
import ScribeCore

/// This Encapsulates the data needed for UI updates. It's current privacy
/// focus is to setup and tear down the Terminal using ~Copyable's bonus of
/// having a deinit for structs.
struct InteractionLoop: ~Copyable {

    private let originalConfig = Terminal.enableRawMode()
    private let scribe: Scribe

    init(_ block: some Block) async {
        let size = Terminal.size()
        self.scribe = await Scribe(
            observing: block, width: size.x, height: size.y)
        Terminal.setup()
    }

    deinit {
        Terminal.restore(originalConfig)
        Terminal.reset()
    }

    func start() async {
        let standardInput = Process().standardInput
        let fileHandleForStandardIn = standardInput as! FileHandle

        var size = Terminal.size()
        // Draw the first frame
        let frame = await scribe.current
        draw(frame, size.x, size.y)
        do {
            for try await byte in fileHandleForStandardIn.asyncByteIterator() {
                // update on input
                guard let code = AsciiKeyCode.decode(keyboard: byte) else {
                    continue
                }

                // Update size for next frame
                size = Terminal.size()
                await scribe.updateSize(width: size.x, height: size.y)

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
            Terminal.reset()
            print(error.localizedDescription)
            return
        }
    }
}

func draw(_ visible: VisibleNode, _ x: Int, _ y: Int) {
    let ascii = visible.drawVisible(x, y).0
    ChromaFrame(ascii, .default, .default).render()
}
