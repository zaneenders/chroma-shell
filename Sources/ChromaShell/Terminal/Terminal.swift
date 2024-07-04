//
//  Terminal.swift
//
//
//  Created by Zane Enders on 2/19/22.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// Sets up the Terminal to be in raw mode so we receive the key commands as
/// they are pressed. This is definitely a HACK on top of the terminal to test
/// out an idea I have been stuck on as It seemed easier then learning how
/// MacOS and other operating systems send key commands to programs.
public struct Terminal: ~Copyable {
    private let prev: termios

    public init() {
        self.prev = Terminal.enableRawMode()
        Terminal.setup()
    }

    /// Restore the original terminal config
    /// Clear the last frame from the screen
    deinit {
        Terminal.restore(prev)
        Terminal.reset()
    }

    private static func restore(_ originalConfig: termios) {
        var term = originalConfig
        // restores the original terminal state
        tcsetattr(FileHandle.standardInput.fileDescriptor, TCSAFLUSH, &term)
    }

    private static func enableRawMode() -> termios {
        // see https://stackoverflow.com/a/24335355/669586
        // init raw: termios variable
        var raw: termios = Terminal.initCStruct()
        // sets raw to a copy of the file handlers attributes
        tcgetattr(FileHandle.standardInput.fileDescriptor, &raw)
        // saves a copy of the original standard output file descriptor to revert back to
        let originalConfig = raw
        // TODO this isn't correct
        // sets magical bits to enable "raw mode" 🤷‍♂️
        //https://code.woboq.org/userspace/glibc/sysdeps/unix/sysv/linux/bits/termios-c_lflag.h.html
        #if os(Linux)
            raw.c_lflag &= UInt32(~(UInt32(ECHO | ICANON | IEXTEN | ISIG)))
        #else  // MacOS
            raw.c_lflag &= UInt(~(UInt32(ECHO | ICANON | IEXTEN | ISIG)))
        #endif
        // changes the file descriptor to raw mode
        tcsetattr(FileHandle.standardInput.fileDescriptor, TCSAFLUSH, &raw)
        return originalConfig
    }

    private static func initCStruct<S>() -> S {
        let structPointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
        let structMemory = structPointer.pointee
        structPointer.deallocate()
        return structMemory
    }

    public var size: TerminalSize {
        // TODO look into the SIGWINCH signal maybe replace this function or
        // its call sites.
        var w: winsize = Terminal.initCStruct()
        //???: Is it possible to get a call back or notification of when the window is resized
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w)
        // Check that we have a valid window size
        // ???: Should this throw instead?
        if w.ws_row == 0 || w.ws_col == 0 {
            return TerminalSize(x: -1, y: -1)
        } else {
            return TerminalSize(
                x: Int(w.ws_col.magnitude), y: Int(w.ws_row.magnitude))
        }
    }

}

public struct TerminalSize: Hashable {
    public let x: Int
    public let y: Int
}

extension Terminal {

    /*
    NOTE Don't use `print` as this adds funky spacing to the output behavior of
    the terminal.
    */

    /// Should be called at the beginning of the program to setup the screen state correctly.
    private static func setup() {
        FileHandle.standardOutput.write(Data(setupCode.utf8))
    }

    /// Used to write the contents of of the frame to the screen.
    public static func write(frame strFrame: String) {
        clear()
        FileHandle.standardOutput.write(Data(strFrame.utf8))
    }

    /// clears the screen to setup, reset or write a new frame to the screen.
    private static func clear() {
        FileHandle.standardOutput.write(Data(Terminal.clearCode.utf8))
    }

    /// Resets the terminal and cursor to the screen.
    public static func reset() {
        clear()
        FileHandle.standardOutput.write(Data(Terminal.restCode.utf8))
    }

    private static var restCode: String {
        AnsiEscapeCode.Cursor.show.rawValue
            + AnsiEscapeCode.Cursor.Style.Block.blinking.rawValue
            + AnsiEscapeCode.home.rawValue
    }

    private static var setupCode: String {
        AnsiEscapeCode.Cursor.hide.rawValue + clearCode
    }

    private static var clearCode: String {
        AnsiEscapeCode.eraseScreen.rawValue + AnsiEscapeCode.eraseSaved.rawValue
            + AnsiEscapeCode.home.rawValue
            + AnsiEscapeCode.Cursor.Style.Block.blinking.rawValue
    }

}
