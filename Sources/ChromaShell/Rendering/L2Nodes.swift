enum L2NodeKind {
    case array
    case button
    case group
    case style
    case switchTo
    case text
    case textEntry
}

protocol L2Node {
    var kind: L2NodeKind { get }
}
struct L2Entry: L2Node {
    let kind: L2NodeKind = .textEntry
    let storage: EntryStorage
}
struct L2Array: L2Node {
    // TODO let orientation: GroupType
    let kind: L2NodeKind = .array
    let nodes: [any L2Node]
}
struct L2Button: L2Node {
    let kind: L2NodeKind = .button
    let label: String
    let action: () -> Void
}
struct L2Group: L2Node {
    let kind: L2NodeKind = .group
    let orientation: GroupOrientation
    let wrapping: any L2Node
}
struct L2Style: L2Node {
    let kind: L2NodeKind = .style
}
struct L2SwitchTo: L2Node {
    let kind: L2NodeKind = .switchTo
}
struct L2Text: L2Node {
    let kind: L2NodeKind = .text
    let text: String
}

extension L1Node {
    /// Walks the L1Node tree and flattens out L1Tuples and L1Composed Nodes as
    /// L2Arrays.
    func flattenTuplesAndComposed() -> any L2Node {
        switch self.kind {
        case .textEntry:
            let t = self as! L1Entry
            return L2Entry(storage: t.storage)
        case .array:
            let a = self as! L1Array
            let l1Nodes = a.nodes.map { $0.flattenTuplesAndComposed() }
            return L2Array(nodes: l1Nodes)
        case .button:
            let b = self as! L1Button
            return L2Button(label: b.label, action: b.action)
        case .group:
            let g = self as! L1Group
            return L2Group(
                orientation: g.orientation,
                wrapping: g.wrapping.flattenTuplesAndComposed())
        case .style:
            fatalError("Style not added yet")
        case .switchTo:
            fatalError("Switch to added yet")
        case .text:
            let t = self as! L1Text
            return L2Text(text: t.text)
        case .composed:
            let c = self as! L1Composed
            return L2Array(nodes: [c.wrapping.flattenTuplesAndComposed()])
        case .tuple:
            let t = self as! L1Tuple
            return L2Array(nodes: [
                t.first.flattenTuplesAndComposed(),
                t.second.flattenTuplesAndComposed(),
            ])
        }
    }
}
