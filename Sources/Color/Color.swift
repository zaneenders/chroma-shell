public typealias ANSIString = String

public enum TerminalColor {
    case reset
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
    }
}

public enum Color {
    case yellow
    case blue
    case pink
    case red
    case orange
    case purple
    case teal
    case white
    case green
    case black
    case `default`
}

public func wrap(
    _ out: String,
    _ foreground: Color = .default,
    _ background: Color = .default
) -> String {

    // Apply foreground color
    let fg: String
    switch foreground {
    case .default:
        fg = defaultColor(out, .foreground)
    case .white:
        fg = white(out, .foreground)
    case .green:
        fg = green(out, .foreground)
    case .black:
        fg = black(out, .foreground)
    case .blue:
        fg = blue(out, .foreground)
    case .orange:
        fg = orange(out, .foreground)
    case .pink:
        fg = pink(out, .foreground)
    case .purple:
        fg = purple(out, .foreground)
    case .red:
        fg = red(out, .foreground)
    case .teal:
        fg = teal(out, .foreground)
    case .yellow:
        fg = yellow(out, .foreground)
    }
    // Apply background color
    let bg: String
    switch background {
    case .default:
        bg = defaultColor(fg, .background)
    case .white:
        bg = white(fg, .background)
    case .green:
        bg = green(fg, .background)
    case .black:
        bg = black(fg, .background)
    case .blue:
        bg = blue(fg, .background)
    case .orange:
        bg = orange(fg, .background)
    case .pink:
        bg = pink(fg, .background)
    case .purple:
        bg = purple(fg, .background)
    case .red:
        bg = red(fg, .background)
    case .teal:
        bg = teal(fg, .background)
    case .yellow:
        bg = yellow(fg, .background)
    }
    return bg
}

public func foreground(_ color: TerminalColor, _ str: String) -> ANSIString {
    // https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
    let colorString: String
    switch color {
    case .reset:
        colorString = "\u{001b}[0m"
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

public func background(_ color: TerminalColor, _ str: String) -> ANSIString {
    // https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
    let colorString: String
    switch color {
    case .reset:
        colorString = "\u{001b}[0m"
    case let .basic(basic):
        switch basic {
        case .black:
            colorString = "\u{001b}[40m"
        case .red:
            colorString = "\u{001b}[41m"
        case .green:
            colorString = "\u{001b}[42m"
        case .yellow:
            colorString = "\u{001b}[43m"
        case .blue:
            colorString = "\u{001b}[44m"
        case .magenta:
            colorString = "\u{001b}[45m"
        case .cyan:
            colorString = "\u{001b}[46m"
        case .white:
            colorString = "\u{001b}[47m"
        }
    case let .bright(bright):
        switch bright {
        case .black:
            colorString = "\u{001b}[40;1m"
        case .red:
            colorString = "\u{001b}[41;1m"
        case .green:
            colorString = "\u{001b}[42;1m"
        case .yellow:
            colorString = "\u{001b}[43;1m"
        case .blue:
            colorString = "\u{001b}[44;1m"
        case .magenta:
            colorString = "\u{001b}[45;1m"
        case .cyan:
            colorString = "\u{001b}[46;1m"
        case .white:
            colorString = "\u{001b}[47;1m"
        }
    case let .int(i):
        colorString = "\u{001b}[48;5;\(i % 256)m"
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
