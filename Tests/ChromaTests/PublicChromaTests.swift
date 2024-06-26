import Chroma
import XCTest

final class PublicChromaTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(
            foreground(TerminalColor.basic(.blue), "Hello"),
            "\u{001b}[34mHello\u{001b}[0m")
    }

    func testWrap() async {
        // TODO test these, this might be a better Test for Chroma
        let a = wrap("#", .black, .white)
        let b = wrap("$", .green, .orange)
        let reset = "\u{001b}[0m"
        let white = "\u{001b}[48;5;\(231)m"
        let black = "\u{001b}[38;5;\(232)m"
        let green = "\u{001b}[38;5;\(40)m"
        let orange = "\u{001b}[48;5;\(202)m"

        let ra = white + black + "#" + reset + reset
        let rb = orange + green + "$" + reset + reset
        XCTAssertEqual(a, ra)
        XCTAssertEqual(b, rb)
    }
}
