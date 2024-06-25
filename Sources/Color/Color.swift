public typealias AnsiString = String

public enum Color {
    case basic(Basic)
    case bright(Basic)
    case int(Int)

    public enum Basic {
        case black
        case red
        case green
        case yellow
        case blue
        case magenta
        case cyan
        case white
        // case reset
    }
}

public func foreground(_ color: Color, _ str: String) -> AnsiString {
    // https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
    let colorString: String
    switch color {
    case let .basic(basic):
        switch basic {
        case .black:
            colorString = "\u{001b}[30m"
        case .red:
            colorString = "\u{001b}[31m"
        case .green:
            colorString = "\u{001b}[32m"
        case .yellow:
            colorString = "\u{001b}[33m"
        case .blue:
            colorString = "\u{001b}[34m"
        case .magenta:
            colorString = "\u{001b}[35m"
        case .cyan:
            colorString = "\u{001b}[36m"
        case .white:
            colorString = "\u{001b}[37m"
        }
    case let .bright(bright):
        switch bright {
        case .black:
            colorString = "\u{001b}[30;1m"
        case .red:
            colorString = "\u{001b}[31;1m"
        case .green:
            colorString = "\u{001b}[32;1m"
        case .yellow:
            colorString = "\u{001b}[33;1m"
        case .blue:
            colorString = "\u{001b}[34;1m"
        case .magenta:
            colorString = "\u{001b}[35;1m"
        case .cyan:
            colorString = "\u{001b}[36;1m"
        case .white:
            colorString = "\u{001b}[37;1m"
        }
    case let .int(i):
        colorString = "\u{001b}[38;5;\(i % 256)m"
    }
    return colorString + str + AnsiCode.reset.rawValue
}

/// Ansi Codes
/// This is only used as a output translation.
/// [](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797)
//!!!: Can we turn this into a DSL
enum AnsiCode: String {

    case esc = "\u{001b}["
    case reset = "\u{001b}[0m"
    case home = "\u{001b}[H"  // moves cursor to home position (0, 0)
    case eraseScreen = "\u{001b}[2J"
    case eraseSaved = "\u{001b}[3J"
    case defaultColor = "\u{001b}[1;39m"
    //    ESC[{line};{column}H
    //    ESC[{line};{column}f    moves cursor to line #, column #
    //    ESC[J    erase in display (same as ESC[0J)
    //    ESC[0J    erase from cursor until end of screen
    //    ESC[1J    erase from cursor to beginning of screen
    //    ESC[2J    erase entire screen
    //    ESC[3J    erase saved lines
    //    ESC[K    erase in line (same as ESC[0K)
    //    ESC[0K    erase from cursor to end of line
    //    ESC[1K    erase start of line to the cursor
    //    ESC[2K    erase the entire line

    enum Style: String {
        case bold = "\u{001b}[1m"
        case underline = "\u{001b}[4m"
        case reversed = "\u{001b}[7m"
    }

    static func foregroundColor(_ value: Int) -> String {
        "\u{001b}[38;5;\(value)m"
    }

    static func backgroundColor(_ value: Int) -> String {
        "\u{001b}[48;5;\(value)m"
    }
}
