/// HeartBeat functions as a way to add async updates to the UI. Currently it
/// can update a String at every half second which is pretty limited but also
/// introduces this requirement early so I can keep the async updates working.
@globalActor
public actor HeartBeat {
    private enum State {
        case notRunning
        case running(Task<(), any Error>)

        var running: Bool {
            switch self {
            case .notRunning:
                return false
            case .running:
                return true
            }
        }
    }

    private init() {
        Task {
            await self.start()
        }
    }

    /// Registers a given function to be updated periodically
    /// This is mostly in place to simulate async updates to the UI but could also be used as a way to update a timer.
    public nonisolated static func register(
        _ update: @escaping (String) -> Void
    ) {
        Task(priority: .userInitiated) {
            // Register the function to perform the local updates.
            await HeartBeat.shared.subscribe(update)
        }
    }

    public static let shared: HeartBeat = HeartBeat()
    private var state: State = .notRunning

    private var connections: [(String) -> Void] = []
    private var connected: Int {
        connections.count
    }

    private func subscribe(_ update: @escaping (String) -> Void) {
        connections.append(update)
        switch self.state {
        case .notRunning:
            start()
        case .running:
            ()
        }
    }

    private func start() {
        let loop = Task {
            var msg = "HeartBeat:"
            while state.running {
                try await Task.sleep(for: .milliseconds(500))
                for s in connections {
                    s(msg)
                    msg += "!"
                }
            }
        }
        self.state = .running(loop)
    }

    private func stop() {
        switch self.state {
        case .notRunning:
            ()
        case let .running(loop):
            loop.cancel()
            self.state = .notRunning
        }
    }
}
