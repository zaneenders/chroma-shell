public enum Position {
    case foreground
    case background
}

public func yellow(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(226), position)
}

public func green(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(40), position)
}

public func blue(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(27), position)
}

public func pink(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(201), position)
}

public func red(_ str: String, _ position: Position = .foreground) -> ANSIString
{
    wrap(str, .int(196), position)
}

public func orange(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(202), position)
}

public func purple(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(129), position)
}

public func white(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(231), position)
}

public func black(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(232), position)
}

public func teal(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .int(14), position)
}

public func defaultColor(_ str: String, _ position: Position = .foreground)
    -> ANSIString
{
    wrap(str, .reset, position)
}

func wrap(_ str: String, _ color: TerminalColor, _ position: Position)
    -> ANSIString
{
    switch position {
    case .foreground:
        return foreground(color, str)
    case .background:
        return background(color, str)
    }
}
