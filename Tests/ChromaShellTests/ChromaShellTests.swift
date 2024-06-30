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
        var pathCopy: SelectedStateNode? = nil
        let t: some Block = Group(.horizontal) {
            "Hello"
            " "
            "World"
        }
        let r = t.readBlockTree(.vertical)
            .flattenTuplesAndComposed()
            .mergeArraysIntoGroups()
            .wrapWithGroup()
            .flattenSimilarGroups()
            .createPath()
            .mergeState(with: &pathCopy)

        /*
        This is roughly what it should be after orientation is passed down
        correctly and sub groups and tuples are merged.
        */
        let expected: SelectedStateNode = .selected(
            .group(
                .entire, .vertical,
                [
                    .group(
                        .entire, .horizontal,
                        [
                            .text("Hello"),
                            .text(" "),
                            .text("World"),
                        ])
                ]))

        XCTAssertEqual(r, expected)
    }
}
