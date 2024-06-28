import Observation

enum Command {
    case `in`
    case `out`
    case up
    case down
    case left
    case right
    case unsafeInput(String)
}

/// This is going to be the core of what makes ChromaShell actually work as it
/// survive where the translation and updates to the given Block are processed
/// and passed to the terminal. This may get moved out of rendering and into
/// Controller or Engine.
actor RenderObserver {
    private let block: any Block
    // Holds the current state between render passes. Mostly updated via
    // commands like up, down, left, right, in, out.
    private var graphState: SelectedStateNode? = nil
    private(set) var mode: Mode = .normal

    init(_ block: some Block) {
        self.block = block
    }

    /// Signal the update to rerender.
    func startObservation() {
        withObservationTracking {
            render()
        } onChange: {
            Task(priority: .userInitiated) { await self.startObservation() }
        }
    }

    /// Used to interact with the graph.
    /// Examples: changing state, pressing buttons, changing position
    func command(_ cmd: Command) {

        // First render() takes care of optional
        let (r, m) = self.graphState!.apply(command: cmd)
        switch (self.mode, cmd) {
        case (.input, .out):
            self.mode = .normal
        default:
            self.mode = m
        }
        render()
        self.graphState = r
    }

    /// Draw to the screen, put the available data on the terminal.
    func render() {
        self.graphState = self.block.pipeline(self.graphState)
    }
}
