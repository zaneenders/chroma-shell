enum L1NodeKind {
    case array
    case button
    case group
    case style
    case switchTo
    case text
    case tuple
    case composed
    case textEntry
}

protocol L1Node {
    var kind: L1NodeKind { get }
}

struct L1Array: L1Node {
    let kind: L1NodeKind = .array
    let nodes: [any L1Node]
    let orientation: GroupOrientation
}
struct L1Entry: L1Node {
    let kind: L1NodeKind = .textEntry
    let storage: EntryStorage
}
struct L1Button: L1Node {
    let kind: L1NodeKind = .button
    let label: String
    let action: () -> Void
}
struct L1Group: L1Node {
    let kind: L1NodeKind = .group
    let orientation: GroupOrientation
    let wrapping: any L1Node
}
struct L1Style: L1Node {
    let kind: L1NodeKind = .style
}
struct L1SwitchTo: L1Node {
    let kind: L1NodeKind = .switchTo
}
struct L1Text: L1Node {
    let kind: L1NodeKind = .text
    let text: String
}
struct L1Tuple: L1Node {
    let kind: L1NodeKind = .tuple
    let first: any L1Node
    let second: any L1Node
    let orientation: GroupOrientation
}
struct L1Composed: L1Node {
    let kind: L1NodeKind = .composed
    let wrapping: any L1Node
    let orientation: GroupOrientation
}

extension Block {
    /// walks the Block tree and converts all nodes to there L1Node counter
    /// part. No information is lost here only created.
    func readBlockTree(_ orientation: GroupOrientation) -> any L1Node {
        if let builtin = self as? any BuiltinBlock {
            switch builtin.type {
            case .textEntry:
                let t = builtin as! TextEntry
                return L1Entry(storage: t.storage)
            case .array:
                let a = builtin as! any ArrayBlocks
                let l1Nodes = a._blocks.map { $0.readBlockTree(orientation) }
                return L1Array(nodes: l1Nodes, orientation: orientation)
            case .button:
                let b = builtin as! Button
                return L1Button(label: b.label, action: b.action)
            case let .group(gOrientation):
                let g = builtin as! Group
                return L1Group(
                    orientation: gOrientation,
                    wrapping: g.wrapped.readBlockTree(gOrientation))
            case .style:
                fatalError("Style not added yet")
            case .switchTo:
                fatalError("Switch to added yet")
            case .text:
                let t = builtin as! Text
                return L1Text(text: t.text)
            // TODO add Spacer()
            case .tuple:
                let t = builtin as! TupleBlock
                return L1Tuple(
                    first: t.first.readBlockTree(orientation),
                    second: t.second.readBlockTree(orientation),
                    orientation: orientation)
            }
        } else {
            return L1Composed(
                wrapping: self.component.readBlockTree(orientation),
                orientation: orientation)
        }
    }
}

extension L1Node {
    /// Walks the L1Node tree and flattens out L1Tuples and L1Composed Nodes as
    /// L2Arrays.
    func flattenTuplesAndComposed() -> L2Node {
        switch self.kind {
        case .textEntry:
            let t = self as! L1Entry
            return .textEntry(t.storage)
        case .array:
            let a = self as! L1Array
            let l1Nodes: [L2Node] = a.nodes.map {
                $0.flattenTuplesAndComposed()
            }
            return .array(a.orientation, l1Nodes)
        case .button:
            let b = self as! L1Button
            return .button(b.label, b.action)
        case .group:
            let g = self as! L1Group
            return .group(g.orientation, g.wrapping.flattenTuplesAndComposed())
        case .style:
            fatalError("Style not added yet")
        case .switchTo:
            fatalError("Switch to added yet")
        case .text:
            let t = self as! L1Text
            return .text(t.text)
        case .composed:
            let c = self as! L1Composed
            return .array(
                c.orientation, [c.wrapping.flattenTuplesAndComposed()])
        case .tuple:
            let t = self as! L1Tuple
            return .array(
                t.orientation,
                [
                    t.first.flattenTuplesAndComposed(),
                    t.second.flattenTuplesAndComposed(),
                ])

        }
    }
}