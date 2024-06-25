import Chroma
import XCTest

final class ChromaTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(
            foreground(Color.basic(.blue), "Hello"),
            "\u{001b}[34mHello\u{001b}[0m")
    }
}
