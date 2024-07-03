import ScribeCore
import XCTest

@testable import ChromaShell

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

    func testHorizontal() async throws {
        let t: some Block = Group(.horizontal) {
            "Hello"
            " "
            "World"
        }
        let height = 24
        let width = 80
        let renderer = await RenderObserver(t, width, height)
        await renderer.command(.out)
        let visible = await renderer.current
        let c = visible.drawVisible(width, height).1
        XCTAssertEqual(c, Consumed(x: width, y: height))
    }

    func testVertical() async throws {
        // TODO fix consumeWidth to append extra width on each row.
        let t: some Block = Group(.vertical) {
            "Hello"
        }
        let height = 24
        let width = 80
        let renderer = await RenderObserver(t, width, height)
        await renderer.command(.out)
        let visible = await renderer.current
        let c = visible.drawVisible(width, height).1
        XCTAssertEqual(c, Consumed(x: width, y: height))
    }
}
