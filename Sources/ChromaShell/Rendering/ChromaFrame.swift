import Chroma

// I would like if this imported from Chroma
public typealias ANSIString = String

/// Contains and represents the information needed to render one frame to the current Terminal.
public struct ChromaFrame {

    private let contents: String

    init(
        _ raw: String,
        _ foreground: Color = .default,
        _ background: Color = .default
    ) {
        self.contents = wrap(raw, foreground, background)
    }

    /// Creates a frame of the current size filled with the given char
    /// NOTE: we can not test this as the terminal has no size. I
    /// wonder if can detect if testing or just have to work around this.
    init(
        fill char: Character,
        _ foreground: Color = .default,
        _ background: Color = .default
    ) {
        var out = ""
        let size = Terminal.size()
        for y in 0...size.y {
            for _ in 1...size.x {
                out += "\(char)"
            }
            if y != size.y {
                out += "\n"
            }
        }
        self.contents = wrap(out, foreground, background)
    }

    /// provides an ANSIString view of the ``ChromaFrame``
    public var asciiView: String {
        // Why does DocC not see this type
        contents
    }
}

extension ChromaFrame {

    /// Draws this ChromaFrame's ASCIIString to the terminal clearing the screen
    /// before hand.
    func render() {
        Terminal.write(frame: asciiView)
    }
}
