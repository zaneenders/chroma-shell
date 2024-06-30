import Chroma

indirect enum VisibleNode {
    // NOTE Maybe replace with .style rendering doesn't care whats selected
    // just what and where things go
    case selected(VisibleNode)
    case button(String)
    case entry(String)
    case group(GroupOrientation, [VisibleNode])
    // case style(VisibleNode)
    case text(String)
}

extension VisibleNode {
    var minX: Int {
        switch self {
        case let .entry(l):
            return l.count
        case let .button(l):
            return l.count
        case let .text(t):
            return t.count
        case let .group(o, children):
            var x = 0
            for c in children {
                switch o {
                case .vertical:
                    x += c.minX
                case .horizontal:
                    x = max(x, c.minX)
                }
            }
            return x
        case let .selected(child):
            return child.minX
        }
    }

    var minY: Int {
        switch self {
        case .button, .text, .entry:
            return 1
        case let .group(o, children):
            var y = 0
            for c in children {
                switch o {
                case .vertical:
                    y = max(y, c.minY)
                case .horizontal:
                    y += c.minY
                }
            }
            return y
        case let .selected(child):
            return child.minY
        }
    }
}

struct Consumed: Equatable {
    let x: Int
    let y: Int
}

extension VisibleNode {
    /// Draw / render the VisibleNode consuming the max width and height given.
    func drawVisible(_ width: Int, _ height: Int) -> (ANSIString, Consumed) {
        switch self {
        case let .entry(s):
            return (s, Consumed(x: s.count, y: 1))
        case let .button(l):
            return (l, Consumed(x: l.count, y: 1))
        case let .text(t):
            return (t, Consumed(x: t.count, y: 1))
        case let .group(orientation, children):
            var xt = 0
            var yt = 0
            var out = ""
            for child in children {
                // TODO check if we can add
                switch orientation {
                /*
                Hmm we need to add all the widths together then consume the renaming space?
                */
                case .horizontal:
                    let (s, c) = child.drawVisible(width - xt, height)
                    yt = c.y
                    xt += c.x
                    out += s
                case .vertical:
                    let (s, c) = child.drawVisible(width, height - yt)
                    yt += c.y
                    xt = c.x
                    out += s
                }
            }
            switch orientation {
            case .horizontal:
                return consumeWidth(
                    out, needed: xt, available: width, height: yt)
            case .vertical:
                return consumeHeight(
                    out, needed: yt, available: height, width: xt)
            }
        case let .selected(child):  // Apply Style?
            let (s, c) = child.drawVisible(width, height)
            return (wrap(s, .black, .pink), c)
        }
    }
}

/// Consumes the given height
private func consumeHeight(
    _ text: String, needed: Int, available height: Int, width: Int
) -> (ANSIString, Consumed) {
    let half = (height - needed) / 2
    let spacer = Array(repeating: " ", count: width).joined()
    let spacing = Array(repeating: spacer, count: half)
    let top = spacing
    var bump = ""
    let bottom = spacing
    var yt = top.count + bump.count + needed + bottom.count
    if yt != width {
        yt += 1
        bump += spacer
    }
    let out =
        top.joined(separator: "") + bump + text
        + bottom.joined(separator: "")
    return (out, Consumed(x: width, y: yt))
}

/// Consumes the given width
private func consumeWidth(
    _ text: String, needed: Int, available width: Int, height: Int
)
    -> (ANSIString, Consumed)
{
    /*
    BUG This only wraps one row not multiple. Maybe I need some notion of Row.
    */
    let half = (width - needed) / 2
    let spacing = Array(repeating: " ", count: half).joined()
    let left = spacing
    var bump = ""
    let right = spacing
    var xt = left.count + bump.count + needed + right.count
    if xt != width {
        xt += 1
        bump += " "
    }
    let out = left + bump + text + right
    return (out, Consumed(x: xt, y: height))
}
