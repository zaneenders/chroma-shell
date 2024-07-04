/// Contains and represents the information needed to render one frame to the current Terminal.
public struct ChromaFrame {

    private let contents: String

    public init(
        _ ascii: String,
        _ foreground: Color = .default,
        _ background: Color = .default
    ) {
        self.contents = _wrap(ascii, foreground, background)
    }

    /// Creates a frame of the current size filled with the given char
    /// NOTE: we can not test this as the test terminal has no size. I
    /// wonder if can detect if testing or just have to work around this.
    init(
        fill char: Character, _ height: Int, _ width: Int,
        _ foreground: Color = .default,
        _ background: Color = .default
    ) {
        var out = ""
        for y in 0...height {
            for _ in 1...width {
                out += "\(char)"
            }
            if y != height {
                out += "\n"
            }
        }
        self.contents = _wrap(out, foreground, background)
    }

    /// provides an ``ANSIString`` view of the ``ChromaFrame``
    public var asciiView: String {
        contents
    }
}

extension ChromaFrame {

    /// Draws this ``ChromaFrame`` by sending ``AnsiEscapeCode`` to the
    /// terminal. Clearing the screen before hand.
    public func render() {
        Terminal.write(frame: asciiView)
    }
}
