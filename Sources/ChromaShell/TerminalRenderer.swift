import ScribeCore

public struct Consumed: Equatable {
    let x: Int
    let y: Int
}

extension VisibleNode {
    /// A this point we can assume that all or most of the ``VisibleNode``
    /// passed to us Almost fit into the height and width we have provided. The
    /// job of this function is to tile or materialize the nodes into ASCII
    /// escape codes.
    /// The following assumptions are being made for now. This is currently
    /// serving as the outline for what I would like the algorithm to be. But
    /// as there isn't something I know a lot about how to do correctly or
    /// really know the best way to achieve this.
    /// Scribe grantees something to be visual selected. This might sound
    /// strange to some of you but if you think of your mouse or finger before
    /// you actually click this is sort of a way of selecting. Obviously those
    /// examples are more complicated and I have ideas to work on them in the
    /// future but best to start with the simplest example which I think is
    /// the terminal and ASCII escape codes. Now It may be best to traverse
    /// the tree to the selected node and then "tile" out from there as I would
    /// like to keep that element in the center of the screen give or take some
    /// margin. Kinda to reflect similar behavior of vim letting you pad the
    /// bottom of the text file.
    /// The Next assumption is that text is to generally be centered in the
    /// middle of the screen for now. Soon after I debug this algorithm I plan
    /// to surface apis for suggesting the text to be left or right, top or
    /// bottom. But I think a nice default is for the text to be centered.
    /// I haven't really thought how to handle clipping or word wrapping yet.
    /// For now I think it's best to just clip the text and allow the user to
    /// pan around the graph. Which will mean I need to extend the
    /// ``VisibleNode`` type to allow deeper selections with in lines/ words
    /// This will also be needed to visualize selecting charters of a word in a
    /// text editor which I am to build with this UI/UX framework.
    /// I guess the last thing I should mentioned is text should consume the
    ///  amount of space possible. Until the size of all nodes is know and we
    ///  know how much space to fill in around the information needing to be
    /// displayed.
    /// Hopefully this helps other developers understanding what is going on
    /// here or at least future Zane. I have a somewhat working example of what
    /// i'm trying to do in the ScribeModel repo. But I made different
    /// assumptions about the AST there so the problem is just different enough
    /// here but it is possible.
    public func drawVisible(_ width: Int, _ height: Int) -> (
        ANSIString, Consumed
    ) {
        #warning("This is very broken and buggy right now")
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
            return (_wrap(s, .black, .pink), c)
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
