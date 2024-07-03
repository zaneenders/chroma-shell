import Foundation
import _Blocks

/// This Encapsulates the data needed for UI updates. It's current privacy
/// focus is to setup and tear down the Terminal using ~Copyable's bonus of
/// having a deinit for structs.
struct InteractionLoop: ~Copyable {

    private let originalConfig = Terminal.enableRawMode()
    private let renderer: RenderObserver

    init(_ block: some Block) {
        let size = Terminal.size()
        self.renderer = RenderObserver(
            block, size.x, size.y, TerminalRenderer.self)
        Terminal.setup()
    }

    deinit {
        Terminal.restore(originalConfig)
        Terminal.reset()
    }

    func start() async {
        let standardInput = Process().standardInput
        let fileHandleForStandardIn = standardInput as! FileHandle

        // Start Observation runtime which displays 1st frame
        await renderer.startObservation()

        do {
            for try await byte in fileHandleForStandardIn.asyncByteIterator() {
                // update on input
                guard let code = AsciiKeyCode.decode(keyboard: byte) else {
                    continue
                }
                let size = Terminal.size()
                await renderer.updateSize(size.x, size.y)
                switch await renderer.mode {
                case .input:
                    switch code {
                    case .ctrlC:
                        await renderer.command(.out)
                    default:
                        // TODO space not working
                        if let input = String(bytes: [byte], encoding: .utf8) {
                            await renderer.command(.unsafeInput(input))
                        }
                    }
                case .normal:
                    switch code {
                    case .ctrlC:
                        return
                    case .lowerCaseL:
                        await renderer.command(.in)
                    case .lowerCaseS:
                        await renderer.command(.out)
                    case .lowerCaseJ:
                        await renderer.command(.down)
                    case .lowerCaseF:
                        await renderer.command(.up)
                    case .lowerCaseK:
                        await renderer.command(.right)
                    case .lowerCaseD:
                        await renderer.command(.left)
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
