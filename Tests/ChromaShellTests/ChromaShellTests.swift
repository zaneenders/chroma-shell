import XCTest

@testable import ChromaShell

struct TestBlock: Block {

    @State var counter = 0
    var component: some Block {
        // TODO fix horizontal rendering bug here
        Group(.horizontal) {
            "Hello"
            " "
            "World"
        }
        Button("\(counter)") {
            counter += 1
        }
        TextEntry("Place Holder")
    }
}

final class ChromaShellTests: XCTestCase {

    /// Test if the ChromaFrame foreground and background reset strings are being applied
    func testChromaFrameDefaults() async throws {
        let text = "Zane Was Here"
        let r = ChromaFrame(text).asciiView
        let reset = "\u{001b}[0m"
        XCTAssertEqual(r, reset + reset + text + reset + reset)
    }

    func testTestDescription() async throws {
        // TODO Can I use SwiftSyntax to test this.
        /*
        let test: SelectedStateNode = .selected(
            .group(.entire, .horizontal, [.button("0", {})]))
        XCTAssertEqual(test, test.testDescription)
        */
    }
}
