import ChromaShell
import Observation

@main
struct TestChromaClient: ChromaShell {
    var main: some Block {
        TestBlock()
    }
}

struct TestBlock: Block {
    var store = DataStorage()

    @State var counter = 0
    var component: some Block {
        Button("\(counter)") {
            counter += 1
        }
        "\(store.storage)"
        TextEntry("Place Holder")
    }
}

@Observable
final class DataStorage {
    var storage = ""

    init() {
        // Simulates async updates from a network or clock
        HeartBeat.register(self.update(_:))
    }

    func update(_ string: String) {
        self.storage = string
    }
}
